// ignore_for_file: unreachable_from_main

@JS()
library;

import 'dart:convert' show LineSplitter, htmlEscape;
import 'dart:js_interop';

import 'package:pubviz/viz/colors.dart';
import 'package:web/web.dart';

final hamburgerBtn =
    document.querySelector('#hamburgerBtn') as HTMLButtonElement;
final controlsPanel =
    document.querySelector('#controls-panel') as HTMLDivElement;
final zoomCheckbox =
    document.querySelector('#zoomCheckbox') as HTMLInputElement;

VizInstance? _vizInstance;

SVGElement? __root;

SVGElement get _root => __root!;

final List<String> _dotContentLines = List.unmodifiable(
  LineSplitter.split(
    ((document.querySelector('#dot') as HTMLScriptElement).innerHTML
            as JSString)
        .toDart
        .trim(),
  ),
);

void main() {
  _process();

  void toggleControls() {
    controlsPanel.classList.toggle('collapsed');
  }

  hamburgerBtn.onClick.listen((_) {
    toggleControls();
  });

  void toggleZoom() {
    zoomCheckbox.checked = !zoomCheckbox.checked;
    __root?.classList.toggle('zoom');
  }

  zoomCheckbox.onChange.listen((_) {
    __root?.classList.toggle('zoom');
  });

  window.onKeyDown.listen((KeyboardEvent event) {
    switch (event.key) {
      case 'c' || 'C':
        toggleControls();
      case 'z' || 'Z':
        toggleZoom();
    }
  });
}

Future<void> _process() async {
  if (__root != null) {
    _root.remove();
    __root = null;
  }

  final watch = Stopwatch()..start();
  try {
    _vizInstance ??= await Viz.instance().toDart;

    final output = _vizInstance!.renderString(
      _dotContentLines.join('\n'),
      RenderOptions(format: 'svg'),
    );
    _updateBody(output);
  } catch (e) {
    final output = '<pre>${htmlEscape.convert(e.toString())}</pre>';
    document.querySelector('#graph-container')!.append(output.toJS);
  } finally {
    print('Total time generating graph: ${watch.elapsed}');
  }
}

void _updateBody(String output) {
  assert(__root == null);

  output = LineSplitter.split(output)
      .where(
        (line) =>
            !line.contains('<!--') &&
            !line.contains('-->') &&
            !line.contains('?xml'),
      )
      .join('\n');

  document
      .querySelector('#graph-container')!
      .insertAdjacentHTML('beforeend', output.toJS);

  __root = document.querySelector('svg') as SVGElement;

  final nodes = _root.querySelectorAll('g.node').elements.map((e) {
    final element = e as SVGGElement;
    final title = element.querySelector('title')!.textContent!;
    element.id = title;

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    final nodeStroke =
        element.querySelector('ellipse')?.getAttribute('stroke') ??
        element.querySelector('polygon')?.getAttribute('stroke') ??
        element.querySelector('path')?.getAttribute('stroke');

    if (isOutdatedColor(nodeStroke)) {
      element.classList.add('outdated');
    }

    return (element: element, id: title);
  }).toList();

  final edges = _root.querySelectorAll('g.edge').elements.map((e) {
    final node = e as SVGGElement;
    final title = node.querySelector('title')!.textContent!;
    final things = title.split('->');
    final from = things[0];
    final to = things[1];
    node
      ..setAttribute('x-from', from)
      ..setAttribute('x-to', to);

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    final textFill = node.querySelector('text')?.getAttribute('fill');
    final edgeStroke =
        node.getAttribute('stroke') ??
        node.querySelector('path')?.getAttribute('stroke') ??
        node.querySelector('polygon')?.getAttribute('stroke');

    if (isOutdatedColor(textFill) || isOutdatedColor(edgeStroke)) {
      node.classList.add('outdated');
    }
    return (element: node, from: from, to: to);
  }).toList();

  for (var entry in nodes) {
    entry.element.onMouseEnter.listen((MouseEvent event) {
      _updateOver(event.currentTarget as SVGGElement, nodes, edges);
    });

    entry.element.onMouseLeave.listen((MouseEvent event) {
      _updateOver(null, nodes, edges);
    });
  }

  for (var entry in edges) {
    entry.element.onMouseEnter.listen((MouseEvent event) {
      _updateOver(event.currentTarget as SVGGElement, nodes, edges);
    });

    entry.element.onMouseLeave.listen((MouseEvent event) {
      _updateOver(null, nodes, edges);
    });
  }
}

void _updateOver(
  SVGGElement? element,
  Iterable<({SVGGElement element, String id})> nodes,
  Iterable<({SVGGElement element, String from, String to})> edges,
) {
  final targetPkg = <String?>[];
  if (element != null) {
    if (element.classList.contains('edge')) {
      targetPkg.addAll([
        element.attributes['x-to'],
        element.attributes['x-from'],
      ]);
    } else {
      assert(element.classList.contains('node'));
      targetPkg.add(element.id);
    }
  }

  for (var node in nodes) {
    if (targetPkg.contains(node.id)) {
      node.element.classList.add('active');
    } else {
      node.element.classList.remove('active');
    }
  }

  final fromNodes = <String>[];
  final toNodes = <String>[];
  for (var edge in edges) {
    final nodeXTo = edge.to;
    final nodeXFrom = edge.from;
    if (targetPkg.length == 2) {
      // then the hover-over is on a line!
      if (targetPkg.contains(nodeXTo) && targetPkg.contains(nodeXFrom)) {
        edge.element.classList.add('active');
      } else {
        edge.element.classList.remove('active');
      }
    } else {
      if (targetPkg.contains(nodeXTo) || targetPkg.contains(nodeXFrom)) {
        if (targetPkg.contains(nodeXTo)) {
          fromNodes.add(nodeXFrom);
        }

        if (targetPkg.contains(nodeXFrom)) {
          toNodes.add(nodeXTo);
        }

        edge.element.classList.add('active');
      } else {
        edge.element.classList.remove('active');
      }
    }
  }

  if (targetPkg.length == 1) {
    final lines = [targetPkg.single];
    if (fromNodes.isNotEmpty) {
      lines.add('  From: ${fromNodes.join(', ')}');
    }
    if (toNodes.isNotEmpty) {
      lines.add('    To: ${toNodes.join(', ')}');
    }
    print(lines.join('\n'));
  }
}

@JS()
// ignore: non_constant_identifier_names
external VizClass get Viz;

extension type VizClass._(JSObject _) implements JSObject {
  external JSPromise<VizInstance> instance();
}

extension type VizInstance._(JSObject _) implements JSObject {
  external String renderString(String src, [RenderOptions options]);
}

extension type RenderOptions._(JSObject _) implements JSObject {
  external factory RenderOptions({String format});

  external String format;
}

extension on NodeList {
  Iterable<Element> get elements sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)! as Element;
    }
  }
}

extension on NamedNodeMap {
  String? operator [](String key) => getNamedItem(key)?.value;
}
