@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:pubviz/src/web/pubviz_app.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

void main() {
  setUp(() {
    final template =
        document.querySelector('#test-dom-template') as HTMLTemplateElement;

    // Reset the DOM to a clean state
    document.querySelector('#test-area')!
      ..innerHTML = ''.toJS
      ..appendChild(template.content.cloneNode(true));
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
