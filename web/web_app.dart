@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'src/pubviz_app.dart';

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
