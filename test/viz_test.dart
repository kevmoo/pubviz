import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/pub_data_service.dart';
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
    PubDataService service;

    setUpAll(() {
      service = PubDataService(d.sandbox);
    });

    test('all dependencies', () async {
      final vp = await VizRoot.forDirectory(service, d.sandbox);

      expect(vp.root.name, 'test_pubspec');
      expect(vp.packages, contains('http'));
      expect(vp.packages, contains('test'));

      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.0.0 <3.0.0'));
    });

    test('direct dependencies only', () async {
      final vp = await VizRoot.forDirectory(
        service,
        d.sandbox,
        directDependencies: true,
      );

      expect(vp.root.name, 'test_pubspec');
      expect(vp.packages, contains('http'));
      expect(vp.packages, isNot(contains('test')));

      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.0.0 <3.0.0'));
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
    'pub',
    ['get', '--offline'],
    workingDirectory: d.sandbox,
  );

  if (pr.exitCode != 0) {
    fail([pr.stdout, pr.stderr].join('\n'));
  }
}
