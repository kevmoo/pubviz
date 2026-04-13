@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:pubviz/src/web/pubviz_app.dart';
import 'package:web/web.dart' as web;

void main() async {
  final url = web.URL('viz_data.js', web.window.location.href).href;
  final module = await importModule(url.toJS).toDart;
  final vizDataString = module
      .getProperty<JSString?>('vizDataString'.toJS)
      ?.toDart;

  if (vizDataString == null) {
    throw StateError('`vizDataString` is not defined locally or globally.');
  }

  await PubvizApp(vizDataString).render();
}
