@JS()
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

import 'src/pubviz_app.dart';

void main() async {
  final url = Uri.parse(window.location.href).resolve('viz_data.js').toString();
  final module = await importModule(url.toJS).toDart;
  final vizDataString = module.getProperty('vizDataString'.toJS) as JSString?;

  if (vizDataString == null) {
    throw StateError('`vizDataString` is not defined locally or globally.');
  }

  final app = PubvizApp(vizDataString);
  await app.run();
}
