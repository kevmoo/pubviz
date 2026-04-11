importScripts('https://cdn.jsdelivr.net/npm/@viz-js/viz@3.25.0/dist/viz-global.js');

let vizInstance = null;

onmessage = async function(e) {
  const { dotString, options } = e.data;
  
  try {
    if (!vizInstance) {
      vizInstance = await Viz.instance();
    }
    const output = vizInstance.renderString(dotString, options);
    postMessage({ success: true, output });
  } catch (error) {
    postMessage({
      success: false,
      error: error.toString(),
      stack: error instanceof Error ? error.stack : ''
    });
  }
};
