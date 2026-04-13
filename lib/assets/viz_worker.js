importScripts('https://cdn.jsdelivr.net/npm/@viz-js/viz@3.25.0/dist/viz-global.js');

let vizPromise = null;

onmessage = async function (e) {
  const { dotString, options, generation } = e.data;

  try {
    if (!vizPromise) {
      vizPromise = Viz.instance();
    }
    const viz = await vizPromise;
    const output = viz.renderString(dotString, options);
    postMessage({ success: true, output, generation });
  } catch (error) {
    postMessage({
      success: false,
      error: error.toString(),
      stack: error instanceof Error ? error.stack : '',
      generation
    });
  }
};
