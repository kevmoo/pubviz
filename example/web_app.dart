import 'dart:convert' show HTML_ESCAPE;
import 'dart:html';
import 'dart:svg' as svg;

import 'package:js/js.dart';

final zoomBtn = querySelector('#zoomBtn') as ButtonElement;
final dotScript = querySelector('#dot') as ScriptElement;

svg.SvgElement _root;

void main() {
  var content = dotScript.innerHtml;

  try {
    var output = Viz(content, 'svg');
    _updateBody(output);
  } catch (e) {
    var output = '<pre>${HTML_ESCAPE.convert(e.toString())}</pre>';
    document.body.appendHtml(output);
  }
}

void _updateBody(String output) {
  document.body.appendHtml(output, treeSanitizer: NodeTreeSanitizer.trusted);
  zoomBtn.style.display = 'block';

  _root = querySelector('svg') as svg.SvgElement;

  zoomBtn.onClick.listen((_) {
    _root.classes.toggle('zoom');
  });

  for (var element in _root.querySelectorAll('g.node')) {
    var title = element.querySelector('title').text;
    element.id = title;
  }

  for (var node in _root.querySelectorAll('g.edge')) {
    var title = node.querySelector('title').text;
    var things = title.split('->');
    node.setAttribute('x-from', things[0]);
    node.setAttribute('x-to', things[1]);
  }

  _root.onMouseOver.listen((MouseEvent event) {
    Element target = event.relatedTarget as Element;

    while (target != null && target is! svg.GElement) {
      target = target.parent;
    }

    if (target != null &&
        (target.classes.contains('edge') || target.classes.contains('node'))) {
      _updateOver(target);
    } else {
      _updateOver(null);
    }
  });

  _root.onMouseLeave.listen((MouseEvent event) {
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
