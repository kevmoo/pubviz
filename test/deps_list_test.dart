import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/deps_list.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

const _write = false;

void main() {
  const depsList = [
    ['deps', 'knarly_deps'],
    ['deps', 'empty_deps'],
    ['deps', 'flutter_gallery'],
    ['deps', 'with_dots'],
    ['mock', 'pub_deps_list'],
    ['mock', 'json_serial'],
  ];

  for (var path in depsList.map((e) => p.joinAll(['test', ...e]))) {
    test(path, () {
      final file = File('$path.txt');
      final deps = DepsList.parse(file.readAsStringSync());

      // ignore: prefer_interpolation_to_compose_strings
      final depsJson = _prettyJsonEncode(deps) + '\n';

      final jsonFile = File('$path.json');

      if (_write) {
        jsonFile.writeAsStringSync(depsJson);
        fail('Set `_write` to false!');
      }

      expect(depsJson, jsonFile.readAsStringSync());
    });
  }
}

String _prettyJsonEncode(Object? content) {
  try {
    return '${_encoder.convert(content)}\n';
  } catch (e) {
    if (e is JsonUnsupportedObjectError) {
      Object? error = e;

      var count = 1;

      while (error is JsonUnsupportedObjectError) {
        final juoe = error;
        print(
          '(${count++}) $error ${juoe.unsupportedObject} '
          '${juoe.unsupportedObject.runtimeType} !!!',
        );
        print(Trace.from(juoe.stackTrace!).terse);
        error = juoe.cause;
      }

      if (error != null) {
        print('(${count++}) $error ???');
        if (error is AssertionError) {
          print(error.stackTrace);
        }
      }
    }
    rethrow;
  }
}

const _encoder = JsonEncoder.withIndent(' ', _toEncodable);

Object? _toEncodable(Object? source) {
  if (source is DepsList) {
    return source.toJson();
  } else if (source is DepsPackageEntry) {
    return source.toJson();
  } else if (source is VersionConstraint) {
    return source.toString();
  }
  throw UnsupportedError('unknown ${source.runtimeType} ${source.hashCode}');
}
