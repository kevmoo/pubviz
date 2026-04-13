@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:pubviz/src/web/interop.dart';
import 'package:pubviz/src/web/pubviz_app.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

void main() {
  setUp(() {
    // Clean up previous test containers to ensure isolation
    final existing = document.querySelectorAll('.test-container');
    for (final e in existing.elements) {
      e.remove();
    }

    final container = document.createElement('div')
      ..className = 'test-container'
      ..innerHTML =
          '''
      <input id="controlsToggle" type="checkbox">
      <input id="zoomCheckbox" type="checkbox">
      <input id="devDependenciesCheckbox" type="checkbox">
      <input id="workspaceOnlyCheckbox" type="checkbox">
      <div id="outdatedCheckboxContainer"></div>
      <input id="outdatedOnlyCheckbox" type="checkbox">
      <div id="deps-in-box"></div>
      <div id="deps-out-box"></div>
      <div id="toast"></div>
      <div id="mobile-overlay"></div>
      <span id="version"></span>
      <div id="graph-container"></div>
      <div id="crash-overlay" class="hidden"></div>
      <pre id="crash-trace"></pre>
    '''
              .toJS;
    document.body!.appendChild(container);

    final script = document.createElement('script') as HTMLScriptElement
      ..textContent = '''
      window.Viz = {
        instance: function() {
          return Promise.resolve({
            renderString: function(src, options) {
              return '<svg id="mock-svg"><g class="node"><title>my_cool_package</title><ellipse stroke="#000000"></ellipse></g></svg>';
            }
          });
        }
      };
      
      window.Worker = function(url) {
        this.postMessage = function(msg) {
          setTimeout(async () => {
            if (this.onmessage) {
              let output = '';
              let success = true;
              let error = '';
              try {
                if (window.Viz && window.Viz.instance) {
                  const viz = await window.Viz.instance();
                  output = viz.renderString(msg.dotString, msg.options);
                } else {
                  output = '<svg id="mock-svg"><g class="node"><title>my_cool_package</title><ellipse stroke="#000000"></ellipse></g></svg>';
                }
              } catch (e) {
                success = false;
                error = e.toString();
              }
              this.onmessage({
                data: {
                  success: success,
                  output: output,
                  error: error,
                  stack: '',
                  generation: msg.generation
                }
              });
            }
          }, 0);
        };
        this.terminate = function() {};
      };
    ''';
    document.body!.appendChild(script);
  });

  test('PubvizApp initializes and sets document title', () {
    PubvizApp(_mockData);

    expect(document.title, equals('pubviz - my_cool_package'));
  });

  test('Toggling zoom checkbox updates SVG class', () async {
    final app = PubvizApp(_mockData);

    await app.render();

    final checkbox =
        document.querySelector('#zoomCheckbox') as HTMLInputElement;
    expect(checkbox.checked, isFalse);

    checkbox
      ..click()
      ..dispatchEvent(Event('change'));

    expect(checkbox.checked, isTrue);

    final svg = document.querySelector('#mock-svg') as SVGElement;
    expect(svg.classList.contains('zoom'), isTrue);
  });

  test('PubvizApp renders SVG using mocked Viz', () async {
    final app = PubvizApp(_mockData);

    await app.render();

    final svg = document.querySelector('#mock-svg');
    expect(svg, isNotNull);
  });

  test('PubvizApp renders real SVG using viz-js from CDN', () async {
    // Delete the mock Viz injected by setUp
    final deleteScript = document.createElement('script') as HTMLScriptElement
      ..textContent = 'delete window.Viz;';
    document.body!.appendChild(deleteScript);

    final script = document.createElement('script') as HTMLScriptElement
      ..src =
          'https://cdn.jsdelivr.net/npm/@viz-js/viz@3.25.0/dist/viz-global.js';
    document.body!.appendChild(script);

    await script.onLoad.first;

    final app = PubvizApp(_mockData);

    await app.render();

    final svg = document.querySelector('svg');
    expect(svg, isNotNull);
    expect(svg!.id, isNot(equals('mock-svg')));
  });
}

const _mockData = '''
{
  "rootPackageName": "my_cool_package",
  "packages": {
    "my_cool_package": {
      "name": "my_cool_package",
      "version": "1.0.0",
      "dependencies": []
    }
  }
}
''';
