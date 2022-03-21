import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/util.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  setUpAll(() async {
    await _initTest();
  });

  test('validate pub completed', () async {
    final type = await FileSystemEntity.type(p.join(d.sandbox, 'pubspec.lock'));

    expect(type, FileSystemEntityType.file);
  });

  group('generate VizRoot', () {
    late PubDataService service;

    setUpAll(() {
      service = PubDataService(d.sandbox);
    });

    test('all dependencies', () async {
      final vp = await VizRoot.forDirectory(service);

      expect(vp.root.name, 'test_pubspec');
      expect(vp.packages, contains('http'));
      expect(vp.packages, contains('test'));
      expect(vp.packages, contains('test_core'));
    });

    test('direct dependencies only', () async {
      final vp = await VizRoot.forDirectory(
        service,
        directDependenciesOnly: true,
      );

      expect(vp.root.name, 'test_pubspec');
      expect(vp.packages, contains('http'));
      expect(vp.packages, contains('test'));
      expect(vp.packages, isNot(contains('test_core')));
    });
  });
}

Future<void> _initTest() async {
  // add pubspec
  final content =
      await File(p.join('test', 'test_pubspec.yaml')).readAsString();

  await d.file('pubspec.yaml', content).create();

  // NOTE: since all dependencies in the the sample pubspec are in pubviz
  //       we can use offline to improve speed.
  final pr = await Process.run(
    dartPath,
    ['pub', 'get', '--offline'],
    workingDirectory: d.sandbox,
  );

  if (pr.exitCode != 0) {
    fail([pr.stdout, pr.stderr].join('\n'));
  }
}
