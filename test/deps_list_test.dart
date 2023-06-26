import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubviz/src/deps_list.dart';
import 'package:test/test.dart';

const _write = false;

void main() {
  const depsList = [
    ['deps', 'knarly_deps'],
    ['deps', 'empty_deps'],
    ['deps', 'flutter_gallery'],
    ['deps', 'with_dots'],
    ['mock', 'pub_deps_list'],
  ];

  for (var path in depsList.map((e) => p.joinAll(['test', ...e]))) {
    test(path, () {
      final file = File('$path.txt');
      final deps = DepsList.parse(file.readAsStringSync());

      // ignore: prefer_interpolation_to_compose_strings
      final depsJson = const JsonEncoder.withIndent(' ').convert(deps) + '\n';

      final jsonFile = File('$path.json');

      if (_write) {
        jsonFile.writeAsStringSync(depsJson);
        fail('Set `_write` to false!');
      }

      expect(depsJson, jsonFile.readAsStringSync());
    });
  }
}
