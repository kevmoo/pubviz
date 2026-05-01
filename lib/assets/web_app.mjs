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
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
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
            AB: a => a.length,
      AC: (x0,x1) => { x0.title = x1 },
      B: s => printToConsole(s),
      BB: (a, i) => a[i],
      BC: (x0,x1) => x0[x1],
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: x0 => x0.textContent,
      CC: x0 => x0.length,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      DC: (x0,x1) => x0.exec(x1),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: x0 => x0.target,
      EC: x0 => x0.index,
      F: () => new Error().stack,
      FB: s => s.trim(),
      FC: (s) => +s,
      G: s => JSON.stringify(s),
      GB: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      GC: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (handle) => clearTimeout(handle),
      HC: (o, p) => o[p],
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => x0.offsetHeight,
      IC: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.F(f,arguments.length,x0) }),
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: x0 => x0.relatedTarget,
      JC: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports.G(f,arguments.length,x0,x1) }),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: (x0,x1) => { x0.id = x1 },
      KC: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      L: o => o === undefined,
      LB: x0 => new Worker(x0),
      LC: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      M: o => String(o),
      MB: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.D(f,arguments.length,x0) }),
      MC: f => f.dartFunction,
      N: (x0,x1) => new URL(x0,x1),
      NB: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.E(f,arguments.length,x0) }),
      NC: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      O: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      OB: x0 => ({format: x0}),
      OC: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      P: (x0,x1) => x0.querySelector(x1),
      PB: (x0,x1,x2) => ({dotString: x0,options: x1,generation: x2}),
      PC: Function.prototype.call.bind(DataView.prototype.getFloat64),
      Q: (x0,x1) => x0.remove(x1),
      QB: (x0,x1) => x0.postMessage(x1),
      QC: Function.prototype.call.bind(DataView.prototype.getFloat32),
      R: (x0,x1) => x0.error(x1),
      RB: (x0,x1) => { x0.onerror = x1 },
      RC: Function.prototype.call.bind(DataView.prototype.getUint32),
      S: (x0,x1) => x0.add(x1),
      SB: (x0,x1) => { x0.onmessage = x1 },
      SC: Function.prototype.call.bind(DataView.prototype.getInt32),
      T: (x0,x1) => x0.info(x1),
      TB: x0 => x0.terminate(),
      TC: Function.prototype.call.bind(DataView.prototype.getUint16),
      U: (string, times) => string.repeat(times),
      UB: x0 => x0.stack,
      UC: Function.prototype.call.bind(DataView.prototype.getInt16),
      V: () => typeof dartUseDateNowForTicks !== "undefined",
      VB: x0 => x0.error,
      VC: Function.prototype.call.bind(DataView.prototype.getUint8),
      W: () => Date.now(),
      WB: x0 => x0.output,
      WC: Function.prototype.call.bind(DataView.prototype.getInt8),
      X: () => 1000 * performance.now(),
      XB: x0 => x0.success,
      XC: o => o.length,
      Y: () => globalThis.console,
      YB: x0 => x0.generation,
      YC: (o, i) => o[i],
      Z: (x0,x1) => { x0.textContent = x1 },
      ZB: x0 => x0.data,
      ZC: o => {
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
      a: x0 => x0.remove(),
      aB: (o, p, r) => o.replaceAll(p, () => r),
      aC: (m) => import(m),
      b: (x0,x1,x2) => x0.insertAdjacentHTML(x1,x2),
      bB: x0 => x0.flags,
      bC: x0 => x0.href,
      c: (x0,x1) => x0.querySelectorAll(x1),
      cB: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      cC: x0 => x0.href,
      d: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      dB: o => o instanceof RegExp,
      dC: x0 => x0.location,
      e: b => !!b,
      eB: Function.prototype.call.bind(String.prototype.toLowerCase),
      eC: () => globalThis.window,
      f: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.C(f,arguments.length,x0) }),
      fB: Object.is,
      g: (l, r) => l === r,
      gB: (x0,x1) => x0.test(x1),
      h: x0 => x0.random(),
      hB: x0 => x0.classList,
      i: o => o,
      iB: () => globalThis.document,
      j: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      jB: (x0,x1) => x0.createElement(x1),
      k: () => globalThis.Math,
      kB: (x0,x1) => x0.appendChild(x1),
      l: (x0,x1) => x0.item(x1),
      lB: (x0,x1) => x0.createTextNode(x1),
      m: o => o,
      mB: (x0,x1) => { x0.checked = x1 },
      n: x0 => x0.length,
      nB: x0 => x0.key,
      o: x0 => x0.checked,
      oB: x0 => x0.altKey,
      p: o => o,
      pB: x0 => x0.metaKey,
      q: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      qB: x0 => x0.ctrlKey,
      r: (x0,x1) => x0.closest(x1),
      rB: x0 => x0.body,
      s: (x0,x1) => x0.contains(x1),
      sB: x0 => x0.hash,
      t: (x0,x1) => x0.querySelector(x1),
      tB: (x0,x1) => { x0.title = x1 },
      u: (x0,x1) => { x0.innerHTML = x1 },
      uB: (x0,x1) => { x0.disabled = x1 },
      v: (x0,x1) => { x0.display = x1 },
      vB: (x0,x1) => { x0.type = x1 },
      w: x0 => x0.style,
      wB: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      x: x0 => x0.id,
      xB: x0 => x0.pathname,
      y: (string, token) => string.split(token),
      yB: x0 => x0.history,
      z: o => o instanceof Array,
      zB: x0 => x0.stopPropagation(),

    };

    const baseImports = {
      _: dart2wasm,
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
    dartInstance.exports.B(dartInstance);

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
