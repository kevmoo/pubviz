@JS()
library web_app;

import 'dart:convert' show HTML_ESCAPE, LineSplitter;
import 'dart:html';
import 'dart:svg' as svg;

import 'package:js/js.dart';

final zoomBtn = querySelector('#zoomBtn') as ButtonElement;

svg.SvgElement _root;

final List<String> _dotContent = new List.unmodifiable(LineSplitter
    .split((querySelector('#dot') as ScriptElement).innerHtml.trim()));

final Set<String> _toIgnore = new Set<String>();

void main() {
  _process();

  zoomBtn.onClick.listen((_) {
    if (_root != null) {
      _root.classes.toggle('zoom');
    }
  });
}

void _process() {
  if (_root != null) {
    _root.remove();
    _root = null;
  }

  var removedLinesContainingNodeDefinitions = <String>[];

  var lines = _dotContent.where((line) {
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

      if (comparisonLine.contains(' $item ') ||
          comparisonLine.contains('"$item"')) {
        if (!comparisonLine.contains('->')) {
          removedLinesContainingNodeDefinitions.add(line);
        }

        return false;
      }
    }
    return true;
  }).toList();

  if (removedLinesContainingNodeDefinitions.isNotEmpty) {
    if (lines.last != '}') {
      throw new StateError('huh?');
    }
    lines.removeLast();
    lines.add('  subgraph cluster0 {');
    lines.add('    label=Removed;');
    lines.add('    style=filled;');
    lines.add('    fillcolor="#dddddd";');
    lines.addAll(removedLinesContainingNodeDefinitions);
    lines.add('  }');
    lines.add('}');
  }

  var watch = new Stopwatch()..start();
  try {
    // Default memory: 16,777,216 - 16 MiB
    // Doubling to 32 MiB
    var output = Viz(lines.join('\n'),
        new VizOptions(format: 'svg', totalMemory: 32 * 1024 * 1024));
    _updateBody(output);
  } catch (e) {
    var output = '<pre>${HTML_ESCAPE.convert(e.toString())}</pre>';
    document.body.appendHtml(output);
  } finally {
    print('Total time: ${watch.elapsed}');
  }
}

void _updateBody(String output) {
  assert(_root == null);

  output = LineSplitter
      .split(output)
      .where((line) =>
          !line.contains('<!--') &&
          !line.contains('-->') &&
          !line.contains('?xml'))
      .join('\n');

  document.body.appendHtml(output, treeSanitizer: NodeTreeSanitizer.trusted);
  zoomBtn.style.display = 'block';

  _root = querySelector('svg') as svg.SvgElement;

  for (var element in _root.querySelectorAll('g.node')) {
    var title = element.querySelector('title').text;
    element.id = title;
  }

  for (var node in _root.querySelectorAll('g.node')) {
    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    var polygonBorder = node.querySelector('polygon')?.getAttribute('stroke');
    if (polygonBorder != null &&
        polygonBorder.toLowerCase().startsWith('#ff')) {
      node.classes.add('outdated');
    }

    node.onClick.listen((MouseEvent event) {
      var target = event.currentTarget as Element;
      if (_toIgnore.add(target.id)) {
        // add succeeded – noop
      } else {
        _toIgnore.remove(target.id);
      }
      _process();
    });
  }

  for (var node in _root.querySelectorAll('g.edge')) {
    var title = node.querySelector('title').text;
    var things = title.split('->');
    node.setAttribute('x-from', things[0]);
    node.setAttribute('x-to', things[1]);

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
    var textFill = node.querySelector('text')?.getAttribute('fill');
    if (textFill != null) {
      assert(textFill.startsWith('#'));
      if (textFill.toLowerCase().startsWith('#ff')) {
        // This is an outdated dependency
        node.classes.add('outdated');
      }
    }
  }

  var nodesOfInterest = _root.querySelectorAll('g.edge, g.node');

  nodesOfInterest.onMouseEnter.listen((MouseEvent event) {
    _updateOver(event.currentTarget as svg.GElement);
  });

  nodesOfInterest.onMouseLeave.listen((MouseEvent event) {
    _updateOver(null);
  });
}

void _updateOver(svg.GElement element) {
  var targetPkg = [];
  if (element != null) {
    if (element.classes.contains('edge')) {
      targetPkg
          .addAll([element.attributes['x-to'], element.attributes['x-from']]);
    } else {
      assert(element.classes.contains('node'));
      targetPkg.add(element.id);
    }
  }

  _root.querySelectorAll('g.node').forEach((Element node) {
    if (targetPkg.contains(node.id)) {
      node.classes.add('active');
    } else {
      node.classes.remove('active');
    }
  });

  _root.querySelectorAll('g.edge').forEach((Element node) {
    if (targetPkg.length == 2) {
      if (targetPkg.contains(node.attributes['x-to']) &&
          targetPkg.contains(node.attributes['x-from'])) {
        node.classes.add('active');
      } else {
        node.classes.remove('active');
      }
    } else {
      if (targetPkg.contains(node.attributes['x-to']) ||
          targetPkg.contains(node.attributes['x-from'])) {
        node.classes.add('active');
      } else {
        node.classes.remove('active');
      }
    }
  });
}

@JS()
// ignore: non_constant_identifier_names
external String Viz(String src, [VizOptions options]);

@JS()
@anonymous
class VizOptions {
  String format;
  int totalMemory;

  external factory VizOptions({String format, int totalMemory});
}
