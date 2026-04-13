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
      _36: s => s.trim(),
      _39: (string, times) => string.repeat(times),
      _40: Function.prototype.call.bind(String.prototype.indexOf),
      _41: (s, p, i) => s.lastIndexOf(p, i),
      _42: (string, token) => string.split(token),
      _43: Object.is,
      _72: (m) => import(m),
      _106: x0 => x0.length,
      _108: (x0,x1) => x0[x1],
      _156: x0 => x0.random(),
      _159: () => globalThis.Math,
      _172: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _173: (handle) => clearTimeout(handle),
      _176: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _178: () => new Error().stack,
      _179: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _180: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _181: (x0,x1) => x0.exec(x1),
      _182: (x0,x1) => x0.test(x1),
      _185: o => o === undefined,
      _187: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _190: o => o instanceof RegExp,
      _191: (l, r) => l === r,
      _192: o => o,
      _193: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      _194: o => o,
      _195: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      _196: o => o,
      _197: b => !!b,
      _198: o => o.length,
      _200: (o, i) => o[i],
      _201: f => f.dartFunction,
      _212: o => String(o),
      _213: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _214: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._214(f,arguments.length,x0) }),
      _215: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._215(f,arguments.length,x0,x1) }),
      _216: o => {
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
      _221: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      _235: x0 => x0.index,
      _237: x0 => x0.flags,
      _244: (o, p) => o[p],
      _255: (x0,x1) => x0.querySelector(x1),
      _256: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._256(f,arguments.length,x0) }),
      _258: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _262: x0 => x0.stopPropagation(),
      _268: x0 => ({format: x0}),
      _271: (x0,x1) => x0.item(x1),
      _272: (x0,x1) => x0.getNamedItem(x1),
      _273: (x0,x1) => ({dotString: x0,options: x1}),
      _276: x0 => x0.success,
      _277: x0 => x0.output,
      _278: x0 => x0.error,
      _279: x0 => x0.stack,
      _280: (x0,x1) => x0.add(x1),
      _281: (x0,x1) => x0.remove(x1),
      _282: (x0,x1) => x0.error(x1),
      _283: (x0,x1) => x0.info(x1),
      _284: x0 => new Worker(x0),
      _285: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._285(f,arguments.length,x0) }),
      _286: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._286(f,arguments.length,x0) }),
      _287: (x0,x1) => x0.postMessage(x1),
      _288: x0 => x0.terminate(),
      _289: x0 => x0.remove(),
      _290: (x0,x1,x2) => x0.insertAdjacentHTML(x1,x2),
      _291: (x0,x1) => x0.querySelectorAll(x1),
      _292: (x0,x1) => x0.querySelector(x1),
      _293: (x0,x1) => x0.getAttribute(x1),
      _294: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _295: (x0,x1) => x0.hasAttribute(x1),
      _296: (x0,x1) => x0.closest(x1),
      _297: (x0,x1) => x0.contains(x1),
      _298: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _299: (x0,x1) => new URL(x0,x1),
      _300: o => o instanceof Array,
      _310: a => a.length,
      _312: (a, i) => a[i],
      _341: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _345: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _348: Function.prototype.call.bind(DataView.prototype.getUint8),
      _350: Function.prototype.call.bind(DataView.prototype.getInt8),
      _352: Function.prototype.call.bind(DataView.prototype.getUint16),
      _354: Function.prototype.call.bind(DataView.prototype.getInt16),
      _356: Function.prototype.call.bind(DataView.prototype.getUint32),
      _358: Function.prototype.call.bind(DataView.prototype.getInt32),
      _364: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _366: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _368: Function.prototype.call.bind(Number.prototype.toString),
      _369: Function.prototype.call.bind(BigInt.prototype.toString),
      _370: Function.prototype.call.bind(Number.prototype.toString),
      _482: (x0,x1) => { x0.title = x1 },
      _512: x0 => x0.offsetHeight,
      _513: x0 => x0.style,
      _1449: x0 => x0.checked,
      _1450: (x0,x1) => { x0.checked = x1 },
      _1454: (x0,x1) => { x0.disabled = x1 },
      _2219: () => globalThis.window,
      _2263: x0 => x0.location,
      _2264: x0 => x0.history,
      _2554: x0 => x0.href,
      _2565: x0 => x0.pathname,
      _2569: x0 => x0.hash,
      _2721: x0 => x0.data,
      _2829: (x0,x1) => { x0.onmessage = x1 },
      _2833: (x0,x1) => { x0.onerror = x1 },
      _4784: x0 => x0.target,
      _4834: x0 => x0.length,
      _4893: x0 => x0.textContent,
      _4894: (x0,x1) => { x0.textContent = x1 },
      _4898: () => globalThis.document,
      _4977: (x0,x1) => { x0.title = x1 },
      _4980: x0 => x0.body,
      _5309: x0 => x0.id,
      _5310: (x0,x1) => { x0.id = x1 },
      _5313: x0 => x0.classList,
      _5316: x0 => x0.attributes,
      _5334: (x0,x1) => { x0.innerHTML = x1 },
      _5448: x0 => x0.value,
      _5647: x0 => x0.relatedTarget,
      _5738: x0 => x0.key,
      _9770: (x0,x1) => { x0.display = x1 },
      _11091: x0 => x0.href,
      _11711: () => globalThis.console,

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
