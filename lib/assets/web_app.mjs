// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
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
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
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
            AB: () => globalThis.Math,
      AC: (x0,x1) => new Blob(x0,x1),
      AD: (x0,x1) => x0[x1],
      B: s => printToConsole(s),
      BB: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      BC: x0 => globalThis.URL.createObjectURL(x0),
      BD: x0 => x0.index,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: (handle) => clearTimeout(handle),
      CC: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.F(f,arguments.length,x0) }),
      CD: x0 => x0.length,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: x0 => x0.offsetHeight,
      DC: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.G(f,arguments.length,x0) }),
      DD: (x0,x1) => x0.exec(x1),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: s => s.trim(),
      EC: (x0,x1) => { x0.src = x1 },
      ED: (s) => +s,
      F: () => new Error().stack,
      FB: x0 => x0.relatedTarget,
      FC: (x0,x1) => { x0.onerror = x1 },
      FD: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      G: s => JSON.stringify(s),
      GB: (x0,x1) => { x0.id = x1 },
      GC: x0 => globalThis.URL.revokeObjectURL(x0),
      GD: (o, p) => o[p],
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (x0,x1) => x0.item(x1),
      HC: (x0,x1) => { x0.onload = x1 },
      HD: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.J(f,arguments.length,x0) }),
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: o => o,
      IC: x0 => x0.getBoundingClientRect(),
      ID: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports.K(f,arguments.length,x0,x1) }),
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: x0 => x0.length,
      JC: (x0,x1) => x0.getContext(x1),
      JD: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: x0 => x0.checked,
      KC: (x0,x1,x2) => x0.scale(x1,x2),
      KD: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      L: o => o === undefined,
      LB: x0 => new Worker(x0),
      LC: (x0,x1,x2,x3,x4) => x0.fillRect(x1,x2,x3,x4),
      LD: f => f.dartFunction,
      M: o => String(o),
      MB: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.D(f,arguments.length,x0) }),
      MC: (x0,x1,x2,x3,x4,x5) => x0.drawImage(x1,x2,x3,x4,x5),
      MD: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      N: (x0,x1) => new URL(x0,x1),
      NB: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.E(f,arguments.length,x0) }),
      NC: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.H(f,arguments.length,x0) }),
      ND: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      O: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      OB: x0 => ({format: x0}),
      OC: (x0,x1,x2) => x0.toBlob(x1,x2),
      OD: Function.prototype.call.bind(DataView.prototype.getFloat64),
      P: (x0,x1) => x0.querySelector(x1),
      PB: (x0,x1,x2) => ({dotString: x0,options: x1,generation: x2}),
      PC: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.I(f,arguments.length,x0) }),
      PD: Function.prototype.call.bind(DataView.prototype.getFloat32),
      Q: (x0,x1) => x0.remove(x1),
      QB: (x0,x1) => x0.postMessage(x1),
      QC: x0 => x0.click(),
      QD: Function.prototype.call.bind(DataView.prototype.getUint32),
      R: (x0,x1) => x0.error(x1),
      RB: (x0,x1) => { x0.onerror = x1 },
      RC: (x0,x1) => { x0.download = x1 },
      RD: Function.prototype.call.bind(DataView.prototype.getInt32),
      S: (x0,x1) => x0.add(x1),
      SB: x0 => x0.terminate(),
      SC: (x0,x1) => { x0.href = x1 },
      SD: Function.prototype.call.bind(DataView.prototype.getUint16),
      T: (x0,x1) => x0.info(x1),
      TB: (x0,x1) => { x0.onmessage = x1 },
      TC: x0 => new ClipboardItem(x0),
      TD: Function.prototype.call.bind(DataView.prototype.getInt16),
      U: (string, times) => string.repeat(times),
      UB: x0 => x0.stack,
      UC: (x0,x1) => x0.write(x1),
      UD: Function.prototype.call.bind(DataView.prototype.getUint8),
      V: () => typeof dartUseDateNowForTicks !== "undefined",
      VB: x0 => x0.error,
      VC: (o, p, v) => o[p] = v,
      VD: Function.prototype.call.bind(DataView.prototype.getInt8),
      W: () => Date.now(),
      WB: x0 => x0.output,
      WC: () => ({}),
      WD: (o, i) => o[i],
      X: () => 1000 * performance.now(),
      XB: x0 => x0.success,
      XC: (x0,x1) => { x0.fillStyle = x1 },
      XD: o => o.length,
      Y: () => globalThis.console,
      YB: x0 => x0.generation,
      YC: (x0,x1) => { x0.height = x1 },
      YD: o => {
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
      Z: (x0,x1) => { x0.textContent = x1 },
      ZB: x0 => x0.data,
      ZC: (x0,x1) => { x0.width = x1 },
      ZD: (m) => import(m),
      a: x0 => x0.remove(),
      aB: (o, p, r) => o.replaceAll(p, () => r),
      aC: x0 => x0.height,
      aD: x0 => x0.href,
      b: (x0,x1,x2) => x0.insertAdjacentHTML(x1,x2),
      bB: x0 => x0.flags,
      bC: x0 => x0.width,
      bD: x0 => x0.href,
      c: (x0,x1) => x0.querySelectorAll(x1),
      cB: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      cC: x0 => new Array(x0),
      cD: x0 => x0.location,
      d: (x0,x1) => x0.closest(x1),
      dB: o => o instanceof RegExp,
      dC: o => [o],
      dD: () => globalThis.window,
      e: (x0,x1) => x0.contains(x1),
      eB: Function.prototype.call.bind(String.prototype.toLowerCase),
      eC: (o0, o1) => [o0, o1],
      f: (x0,x1) => x0.querySelector(x1),
      fB: Object.is,
      fC: (o0, o1, o2) => [o0, o1, o2],
      g: (x0,x1) => { x0.innerHTML = x1 },
      gB: (x0,x1) => x0.test(x1),
      gC: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      h: (x0,x1) => { x0.display = x1 },
      hB: x0 => x0.classList,
      hC: (x0,x1,x2) => { x0[x1] = x2 },
      i: x0 => x0.style,
      iB: () => globalThis.document,
      iC: (x0,x1) => x0.item(x1),
      j: x0 => x0.id,
      jB: (x0,x1) => x0.createElement(x1),
      jC: (x0,x1) => x0.item(x1),
      k: (string, token) => string.split(token),
      kB: (x0,x1) => x0.appendChild(x1),
      kC: x0 => x0.cssText,
      l: o => o instanceof Array,
      lB: (x0,x1) => x0.createTextNode(x1),
      lC: x0 => x0.length,
      m: (a, i) => a[i],
      mB: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      mC: x0 => x0.cssRules,
      n: a => a.length,
      nB: x0 => x0.pathname,
      nC: x0 => x0.href,
      o: x0 => x0.textContent,
      oB: x0 => x0.history,
      oC: x0 => x0.length,
      p: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      pB: (x0,x1) => { x0.checked = x1 },
      pC: x0 => x0.styleSheets,
      q: o => o,
      qB: x0 => x0.disabled,
      qC: x0 => x0.outerHTML,
      r: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      rB: x0 => x0.key,
      rC: x0 => x0.clipboard,
      s: (l, r) => l === r,
      sB: x0 => x0.altKey,
      sC: (o, p) => p in o,
      t: x0 => x0.target,
      tB: x0 => x0.metaKey,
      tC: x0 => x0.navigator,
      u: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      uB: x0 => x0.ctrlKey,
      uC: (x0,x1) => { x0.className = x1 },
      v: b => !!b,
      vB: x0 => x0.stopPropagation(),
      vC: (x0,x1) => { x0.disabled = x1 },
      w: (module,f) => finalizeWrapper(f, function(x0) { return module.exports.C(f,arguments.length,x0) }),
      wB: x0 => x0.body,
      wC: (x0,x1) => { x0.title = x1 },
      x: x0 => x0.random(),
      xB: x0 => x0.hash,
      xC: (x0,x1) => { x0.disabled = x1 },
      y: o => o,
      yB: (x0,x1) => x0.writeText(x1),
      yC: (x0,x1) => { x0.type = x1 },
      z: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      zB: x0 => ({type: x0}),
      zC: (x0,x1) => { x0.title = x1 },

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
