// ignore_for_file: unreachable_from_main

@JS()
library;

import 'dart:convert' show LineSplitter, htmlEscape;
import 'dart:js_interop';

import 'package:web/web.dart';

final zoomBtn = document.querySelector('#zoomBtn') as HTMLButtonElement;

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

void _process() {
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
    // Default memory: 16,777,216 - 16 MiB
    // Doubling to 32 MiB
    final output = Viz(
      lines.join('\n'),
      VizOptions(format: 'svg', totalMemory: 32 * 1024 * 1024),
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

  for (var element in _root.querySelectorAll('g.node').elements) {
    final title = element.querySelector('title')!.textContent!;
    element.id = title;
  }

  for (var node in _root.querySelectorAll('g.node').elements) {
    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    final polygonBorder = node.querySelector('polygon')?.getAttribute('stroke');
    if (polygonBorder != null &&
        polygonBorder.toLowerCase().startsWith('#ff')) {
      node.classList.add('outdated');
    }

    node.onClick.listen((MouseEvent event) {
      final target = event.currentTarget as Element;
      if (_toIgnore.add(target.id)) {
        // add succeeded – noop
      } else {
        _toIgnore.remove(target.id);
      }
      _process();
    });
  }

  for (var node in _root.querySelectorAll('g.edge').elements) {
    final title = node.querySelector('title')!.textContent!;
    final things = title.split('->');
    node
      ..setAttribute('x-from', things[0])
      ..setAttribute('x-to', things[1]);

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    final textFill = node.querySelector('text')?.getAttribute('fill');
    if (textFill != null) {
      assert(textFill.startsWith('#'));
      if (textFill.toLowerCase().startsWith('#ff')) {
        // This is an outdated dependency
        node.classList.add('outdated');
      }
    }
  }

  final nodesOfInterest = _root.querySelectorAll('g.edge, g.node');

  for (var interest in nodesOfInterest.elements) {
    interest.onMouseEnter.listen((MouseEvent event) {
      _updateOver(event.currentTarget as SVGGElement);
    });

    interest.onMouseLeave.listen((MouseEvent event) {
      _updateOver(null);
    });
  }
}

void _updateOver(SVGGElement? element) {
  final targetPkg = <String?>[];
  if (element != null) {
    if (element.classList.contains('edge')) {
      targetPkg
          .addAll([element.attributes['x-to'], element.attributes['x-from']]);
    } else {
      assert(element.classList.contains('node'));
      targetPkg.add(element.id);
    }
  }

  for (var node in _root.querySelectorAll('g.node').elements) {
    if (targetPkg.contains(node.id)) {
      node.classList.add('active');
    } else {
      node.classList.remove('active');
    }
  }

  final fromNodes = <String>[];
  final toNodes = <String>[];
  for (var node in _root.querySelectorAll('g.edge').elements) {
    final nodeXTo = node.attributes['x-to']!;
    final nodeXFrom = node.attributes['x-from']!;
    if (targetPkg.length == 2) {
      // then the hover-over is on a line!
      if (targetPkg.contains(nodeXTo) && targetPkg.contains(nodeXFrom)) {
        node.classList.add('active');
      } else {
        node.classList.remove('active');
      }
    } else {
      if (targetPkg.contains(nodeXTo) || targetPkg.contains(nodeXFrom)) {
        if (targetPkg.contains(nodeXTo)) {
          fromNodes.add(nodeXFrom);
        }

        if (targetPkg.contains(nodeXFrom)) {
          toNodes.add(nodeXTo);
        }

        node.classList.add('active');
      } else {
        node.classList.remove('active');
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
external String Viz(String src, [VizOptions options]);

extension type VizOptions._(JSObject _) implements JSObject {
  external VizOptions({String format, int totalMemory});

  external String format;
  external int totalMemory;
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
