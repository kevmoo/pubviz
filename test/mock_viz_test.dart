import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/service.dart';
import 'package:pubviz/viz/dot.dart';
import 'package:test/test.dart';

import 'mock_data_service.dart';

final _mockPath = p.join('test', 'mock');

void main() {
  group('generate VizRoot', () {
    Service service;

    setUpAll(() {
      service = MockDataService(_mockPath);
    });

    test('all dependencies', () async {
      final vp = await VizRoot.forDirectory(service);

      expect(vp.root.name, 'repo_manager');
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
        directDependenciesOnly: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(27));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(27),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        isEmpty,
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'direct_deps');
    });

    test('prod dependencies only', () async {
      final vp = await VizRoot.forDirectory(
        service,
        productionDependenciesOnly: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(71));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(22),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(49),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'production_deps');
    });

    test('prod + direct dependencies only', () async {
      final vp = await VizRoot.forDirectory(
        service,
        directDependenciesOnly: true,
        productionDependenciesOnly: true,
      );

      expect(vp.root.name, 'repo_manager');
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

      _verifyDotOutput(vp, 'direct_production_deps');
    });

    test('outdated', () async {
      final vp = await VizRoot.forDirectory(
        service,
        flagOutdated: true,
      );

      expect(vp.root.name, 'repo_manager');
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
        flagOutdated: true,
        ignorePackages: ignoredPackages,
      );

      expect(vp.root.name, 'repo_manager');
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
