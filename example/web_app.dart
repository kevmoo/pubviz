@JS()
library web_app;

import 'dart:convert' show htmlEscape, LineSplitter;
import 'dart:html';
import 'dart:svg' as svg;

import 'package:js/js.dart';

final zoomBtn = querySelector('#zoomBtn') as ButtonElement;

svg.SvgElement? __root;

svg.SvgElement get _root => __root!;

final List<String> _dotContentLines = List.unmodifiable(
  LineSplitter.split(
    (querySelector('#dot') as ScriptElement).innerHtml!.trim(),
  ),
);

final _toIgnore = <String>{};

void main() {
  _process();

  zoomBtn.onClick.listen((_) {
    __root?.classes.toggle('zoom');
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
    document.body!.appendHtml(output);
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

  document.body!.appendHtml(output, treeSanitizer: NodeTreeSanitizer.trusted);
  zoomBtn.style.display = 'block';

  __root = querySelector('svg') as svg.SvgElement;

  for (var element in _root.querySelectorAll('g.node')) {
    final title = element.querySelector('title')!.text!;
    element.id = title;
  }

  for (var node in _root.querySelectorAll('g.node')) {
    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    final polygonBorder = node.querySelector('polygon')?.getAttribute('stroke');
    if (polygonBorder != null &&
        polygonBorder.toLowerCase().startsWith('#ff')) {
      node.classes.add('outdated');
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

  for (var node in _root.querySelectorAll('g.edge')) {
    final title = node.querySelector('title')!.text!;
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
        node.classes.add('outdated');
      }
    }
  }

  final nodesOfInterest = _root.querySelectorAll('g.edge, g.node');

  nodesOfInterest.onMouseEnter.listen((MouseEvent event) {
    _updateOver(event.currentTarget as svg.GElement);
  });

  nodesOfInterest.onMouseLeave.listen((MouseEvent event) {
    _updateOver(null);
  });
}

void _updateOver(svg.GElement? element) {
  final targetPkg = <String?>[];
  if (element != null) {
    if (element.classes.contains('edge')) {
      targetPkg
          .addAll([element.attributes['x-to'], element.attributes['x-from']]);
    } else {
      assert(element.classes.contains('node'));
      targetPkg.add(element.id);
    }
  }

  for (var node in _root.querySelectorAll('g.node')) {
    if (targetPkg.contains(node.id)) {
      node.classes.add('active');
    } else {
      node.classes.remove('active');
    }
  }

  final fromNodes = <String>[];
  final toNodes = <String>[];
  for (var node in _root.querySelectorAll('g.edge')) {
    if (targetPkg.length == 2) {
      // then the hover-over is on a line!
      if (targetPkg.contains(node.attributes['x-to']) &&
          targetPkg.contains(node.attributes['x-from'])) {
        node.classes.add('active');
      } else {
        node.classes.remove('active');
      }
    } else {
      if (targetPkg.contains(node.attributes['x-to']) ||
          targetPkg.contains(node.attributes['x-from'])) {
        if (targetPkg.contains(node.attributes['x-to'])) {
          fromNodes.add(node.attributes['x-from']!);
        }

        if (targetPkg.contains(node.attributes['x-from'])) {
          toNodes.add(node.attributes['x-to']!);
        }

        node.classes.add('active');
      } else {
        node.classes.remove('active');
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

@JS()
@anonymous
class VizOptions {
  external String format;
  external int totalMemory;

  external factory VizOptions({String format, int totalMemory});
}
