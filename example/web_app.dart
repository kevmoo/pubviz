import 'dart:convert' show HTML_ESCAPE;
import 'dart:html';
import 'dart:js' as js;
import 'dart:svg' as svg;

final zoomBtn = querySelector('#zoomBtn') as ButtonElement;
final dotScript = querySelector('#dot') as ScriptElement;

void main() {
  var content = dotScript.innerHtml;

  try {
    var output = _runViz(content, 'svg');
    _updateBody(output);
  } catch (e) {
    var output = '<pre>${HTML_ESCAPE.convert(e.toString())}</pre>';
    document.body.appendHtml(output);
  }
}

void _updateBody(String output) {
  document.body.appendHtml(output);
  zoomBtn.style.display = 'block';

  var root = querySelector('svg');

  zoomBtn.onClick.listen((_) {
    root.classes.toggle('zoom');
  });
}

String _runViz(String content, String tag) =>
    js.context.callMethod('Viz', [content, tag]);
