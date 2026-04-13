import 'dart:js_interop';

import 'package:web/web.dart';

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

extension NodeListExt on NodeList {
  Iterable<Element> get elements sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)! as Element;
    }
  }
}

extension NamedNodeMapExt on NamedNodeMap {
  String? operator [](String key) => getNamedItem(key)?.value;
}

extension type RenderMessage._(JSObject _) implements JSObject {
  external factory RenderMessage({
    String dotString,
    RenderOptions options,
    int generation,
  });
  external String get dotString;
  external RenderOptions get options;
  external int get generation;
}

extension type RenderResponse._(JSObject _) implements JSObject {
  external bool get success;
  external String get output;
  external String get error;
  external String? get stack;
  external int get generation;
}
