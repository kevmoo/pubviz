// ignore_for_file: unreachable_from_main

@JS()
library;

import 'dart:convert' show LineSplitter, htmlEscape;
import 'dart:js_interop';

import 'package:web/web.dart';

final zoomBtn = document.querySelector('#zoomBtn') as HTMLButtonElement;

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

final _toIgnore = <String>{};

void main() {
  _process();

  zoomBtn.onClick.listen((_) {
    __root?.classList.toggle('zoom');
  });
}

Future<void> _process() async {
  if (__root != null) {
    _root.remove();
    __root = null;
  }

  final removedLinesContainingNodeDefinitions = <String>[];

  List<String> lines;

  if (_toIgnore.isEmpty) {
    lines = _dotContentLines;
  } else {
    print('Ignoring: ${_toIgnore.join(',')}');
    lines = _dotContentLines.where((line) {
      for (var item in _toIgnore) {
        if (line == 'digraph $item {') {
          return true;
        }

        var comparisonLine = line;
        // for the purposes of this code, ignore anything after and including [
        final openBracketIndex = line.indexOf('[');
        if (openBracketIndex > 0) {
          comparisonLine = comparisonLine.substring(0, openBracketIndex);
        }

        if (comparisonLine.contains(RegExp('\\W$item\\W'))) {
          if (!comparisonLine.contains('->')) {
            removedLinesContainingNodeDefinitions.add(line);
          }

          return false;
        }
      }
      return true;
    }).toList();

    if (removedLinesContainingNodeDefinitions.isEmpty) {
      print('Weird - nothing removed?');
    } else {
      if (lines.last != '}') {
        throw StateError('huh?');
      }
      lines
        ..removeLast()
        ..add('  subgraph cluster0 {')
        ..add('    label=Removed;')
        ..add('    style=filled;')
        ..add('    fillcolor="#dddddd";')
        ..addAll(removedLinesContainingNodeDefinitions)
        ..add('  }')
        ..add('}');
    }
  }

  final watch = Stopwatch()..start();
  try {
    _vizInstance ??= await Viz.instance().toDart;

    final output = _vizInstance!.renderString(
      lines.join('\n'),
      RenderOptions(format: 'svg'),
    );
    _updateBody(output);
  } catch (e) {
    final output = '<pre>${htmlEscape.convert(e.toString())}</pre>';
    document.body!.append(output.toJS);
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

  document.body!.insertAdjacentHTML('beforeend', output.toJS);
  zoomBtn.style.display = 'block';

  __root = document.querySelector('svg') as SVGElement;

  final nodes = _root.querySelectorAll('g.node').elements.map((e) {
    final element = e as SVGGElement;
    final title = element.querySelector('title')!.textContent!;
    element.id = title;

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    final polygonBorder = element
        .querySelector('polygon')
        ?.getAttribute('stroke');
    if (polygonBorder != null &&
        polygonBorder.toLowerCase().startsWith('#ff')) {
      element.classList.add('outdated');
    }

    element.onClick.listen((MouseEvent event) {
      final target = event.currentTarget as Element;
      if (_toIgnore.add(target.id)) {
        // add succeeded – noop
      } else {
        _toIgnore.remove(target.id);
      }
      _process();
    });

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
    if (textFill != null) {
      if (textFill.toLowerCase().startsWith('#ff')) {
        // This is an outdated dependency
        node.classList.add('outdated');
      }
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
