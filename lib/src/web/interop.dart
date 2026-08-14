import 'dart:js_interop';

import 'package:web/web.dart';

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
