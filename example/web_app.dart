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

  var removedLines = <String>[];

  var lines = _dotContent.where((line) {
    for (var item in _toIgnore) {
      if (line.contains('"$item"')) {
        if (!line.contains('->')) {
          removedLines.add(line);
        }

        return false;
      }
    }
    return true;
  }).toList();

  if (removedLines.isNotEmpty) {
    if (lines.last != '}') {
      throw 'huh?';
    }
    lines.removeLast();
    lines.add('  subgraph cluster0 {');
    lines.add('    label=Removed;');
    lines.add('    style=filled;');
    lines.add('    fillcolor="#dddddd";');
    lines.addAll(removedLines);
    lines.add('  }');
    lines.add('}');
  }

  try {
    var output = Viz(lines.join('\n'), 'svg');
    _updateBody(output);
  } catch (e) {
    var output = '<pre>${HTML_ESCAPE.convert(e.toString())}</pre>';
    document.body.appendHtml(output);
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

  _root.querySelectorAll('g.node').onClick.listen((MouseEvent event) {
    var target = event.currentTarget as Element;
    if (_toIgnore.add(target.id)) {} else {
      _toIgnore.remove(target.id);
    }
    _process();
  });

  for (var node in _root.querySelectorAll('g.edge')) {
    var title = node.querySelector('title').text;
    var things = title.split('->');
    node.setAttribute('x-from', things[0]);
    node.setAttribute('x-to', things[1]);
  }

  var nodesOfInterest = _root.querySelectorAll('g.edge, g.node');

  nodesOfInterest.onMouseEnter.listen((MouseEvent event) {
    _updateOver(event.currentTarget);
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
external String Viz(String content, String tag);
