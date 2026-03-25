// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `load-ids` option is passed. Each load ID maps to one
  //   or more wasm files as specified in the emitted JSON file. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It also takes a callback that should be invoked with the
  //   loaded module in a format supported by `WebAssembly.compile` or
  //   `WebAssembly.compileStreaming` and the result of using the JS 'import'
  //   API on the js file path. It should return a Promise that resolves when
  //   all the modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports,
      {loadDeferredModules, loadDynamicModule, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _4: (s) => +s,
      _8: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _9: () => typeof dartUseDateNowForTicks !== "undefined",
      _10: () => 1000 * performance.now(),
      _11: () => Date.now(),
      _29: s => JSON.stringify(s),
      _30: s => printToConsole(s),
      _31: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      _32: (o, p, r) => o.replaceAll(p, () => r),
      _34: Function.prototype.call.bind(String.prototype.toLowerCase),
      _35: s => s.toUpperCase(),
      _36: s => s.trim(),
      _39: (string, times) => string.repeat(times),
      _40: Function.prototype.call.bind(String.prototype.indexOf),
      _41: (s, p, i) => s.lastIndexOf(p, i),
      _42: (string, token) => string.split(token),
      _43: Object.is,
      _71: (m) => import(m),
      _83: x0 => x0.length,
      _85: (x0,x1) => x0[x1],
      _133: x0 => x0.random(),
      _136: () => globalThis.Math,
      _153: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _155: () => new Error().stack,
      _156: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _157: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _158: (x0,x1) => x0.exec(x1),
      _159: (x0,x1) => x0.test(x1),
      _162: o => o === undefined,
      _164: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _167: o => o instanceof RegExp,
      _168: (l, r) => l === r,
      _169: o => o,
      _170: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      _171: o => o,
      _172: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      _173: o => o,
      _174: b => !!b,
      _175: o => o.length,
      _177: (o, i) => o[i],
      _178: f => f.dartFunction,
      _189: o => String(o),
      _190: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _191: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._191(f,arguments.length,x0) }),
      _192: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._192(f,arguments.length,x0,x1) }),
      _193: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _198: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      _212: x0 => x0.index,
      _214: x0 => x0.flags,
      _221: (o, p) => o[p],
      _232: (x0,x1) => x0.querySelector(x1),
      _233: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._233(f,arguments.length,x0) }),
      _235: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _239: x0 => x0.stopPropagation(),
      _242: (x0,x1) => x0.toggle(x1),
      _243: x0 => x0.remove(),
      _244: x0 => x0.instance(),
      _245: x0 => ({format: x0}),
      _246: (x0,x1,x2) => x0.renderString(x1,x2),
      _247: (x0,x1) => x0.append(x1),
      _248: (x0,x1,x2) => x0.insertAdjacentHTML(x1,x2),
      _249: (x0,x1) => x0.querySelectorAll(x1),
      _250: (x0,x1) => x0.querySelector(x1),
      _251: (x0,x1) => x0.getAttribute(x1),
      _252: (x0,x1) => x0.add(x1),
      _253: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _254: (x0,x1) => x0.hasAttribute(x1),
      _255: (x0,x1) => x0.contains(x1),
      _256: (x0,x1) => x0.remove(x1),
      _257: () => globalThis.Viz,
      _260: (x0,x1) => x0.item(x1),
      _261: (x0,x1) => x0.getNamedItem(x1),
      _262: o => o instanceof Array,
      _272: a => a.length,
      _274: (a, i) => a[i],
      _303: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _307: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _310: Function.prototype.call.bind(DataView.prototype.getUint8),
      _312: Function.prototype.call.bind(DataView.prototype.getInt8),
      _314: Function.prototype.call.bind(DataView.prototype.getUint16),
      _316: Function.prototype.call.bind(DataView.prototype.getInt16),
      _318: Function.prototype.call.bind(DataView.prototype.getUint32),
      _320: Function.prototype.call.bind(DataView.prototype.getInt32),
      _326: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _328: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _330: Function.prototype.call.bind(Number.prototype.toString),
      _331: Function.prototype.call.bind(BigInt.prototype.toString),
      _332: Function.prototype.call.bind(Number.prototype.toString),
      _444: (x0,x1) => { x0.title = x1 },
      _475: x0 => x0.style,
      _1411: x0 => x0.checked,
      _1412: (x0,x1) => { x0.checked = x1 },
      _1416: (x0,x1) => { x0.disabled = x1 },
      _2181: () => globalThis.window,
      _2225: x0 => x0.location,
      _2516: x0 => x0.href,
      _4750: x0 => x0.currentTarget,
      _4798: x0 => x0.length,
      _4857: x0 => x0.textContent,
      _4858: (x0,x1) => { x0.textContent = x1 },
      _4862: () => globalThis.document,
      _4941: (x0,x1) => { x0.title = x1 },
      _5273: x0 => x0.id,
      _5274: (x0,x1) => { x0.id = x1 },
      _5277: x0 => x0.classList,
      _5280: x0 => x0.attributes,
      _5298: (x0,x1) => { x0.innerHTML = x1 },
      _5412: x0 => x0.value,
      _5702: x0 => x0.key,
      _9734: (x0,x1) => { x0.display = x1 },

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });
    dartInstance.exports.$setThisModule(dartInstance);

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
