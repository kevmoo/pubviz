@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/root_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  setUpAll(() async {
    await _initTest();
  });

  test('validate pub completed', () async {
    final type = await FileSystemEntity.type(p.join(d.sandbox, 'pubspec.lock'));

    check(type).equals(FileSystemEntityType.file);
  });

  group('generate VizRoot', () {
    late PubDataService service;

    setUpAll(() {
      service = PubDataService(d.sandbox);
    });

    test('all dependencies', () async {
      final vp = await service.vizRoot();

      check(vp.root.name).equals('test_pubspec');
      check(vp.packages)
        ..containsKey('http')
        ..containsKey('test')
        ..containsKey('test_core');
    });

    test('direct dependencies only', () async {
      final vp = await service.vizRoot(directDependenciesOnly: true);

      check(vp.root.name).equals('test_pubspec');
      check(vp.packages)
        ..containsKey('http')
        ..containsKey('test')
        ..not((it) => it.containsKey('test_core'));
    });
  });
}

Future<void> _initTest() async {
  // add pubspec
  final content = await File(
    p.join('test', 'test_pubspec.yaml'),
  ).readAsString();

  await d.file('pubspec.yaml', content).create();

  // NOTE: since all dependencies in the the sample pubspec are in pubviz
  //       we can use offline to improve speed.
  final pr = await Process.run(Platform.executable, [
    'pub',
    'get',
    '--offline',
  ], workingDirectory: d.sandbox);

  if (pr.exitCode != 0) {
    fail([pr.stdout, pr.stderr].join('\n'));
  }
}
