import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/service.dart';
import 'package:pubviz/viz/dot.dart';
import 'package:test/test.dart';

import 'mock_data_service.dart';

final _mockPath = p.join('test', 'mock');

void main() {
  test("don't generate by default", () {
    expect(
      populateFiles,
      false,
      reason: 'Should only be true during development.',
    );
  });

  group('generate VizRoot', () {
    Service service;

    setUpAll(() {
      service = MockDataService(_mockPath);
    });

    test('all dependencies', () async {
      final vp = await VizRoot.forDirectory(service, _mockPath);

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(90));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(27),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(63),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'all_deps');
    });

    test('direct dependencies only', () async {
      final vp = await VizRoot.forDirectory(
        service,
        _mockPath,
        directDependencies: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(22));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(22),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        isEmpty,
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'direct_deps');
    });

    test('outdated', () async {
      final vp = await VizRoot.forDirectory(
        service,
        _mockPath,
        flagOutdated: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(90));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(27),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(63),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'outdated');
    });

    test('ignore', () async {
      final ignoredPackages = ['markdown', 'shelf', 'build_runner'];
      final vp = await VizRoot.forDirectory(
        service,
        _mockPath,
        flagOutdated: true,
        ignorePackages: ignoredPackages,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(90));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(27),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(63),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'ignore', ignoredPackages: ignoredPackages);
    });
  });
}

const _writeOutput = false;

void _verifyDotOutput(
  VizRoot root,
  String name, {
  Iterable<String> ignoredPackages,
}) {
  final dotOutput = toDot(root, ignorePackages: ignoredPackages);

  final filePath = p.join(_mockPath, '$name.dot');

  if (_writeOutput) {
    File(filePath).writeAsStringSync(dotOutput);
    fail('Set `_writeOutput` to false!');
  }

  printOnFailure(dotOutput);

  final fileContent = File(filePath).readAsStringSync();

  expect(dotOutput, fileContent);
}
