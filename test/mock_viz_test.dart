import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/service.dart';
import 'package:pubviz/src/update_order.dart';
import 'package:pubviz/viz/dot.dart';
import 'package:test/test.dart';

import 'mock_data_service.dart';

final _mockPath = p.join('test', 'mock');

void main() {
  group('generate VizRoot', () {
    late Service service;

    setUpAll(() {
      service = MockDataService(_mockPath);
    });

    test('all dependencies', () async {
      final vp = await VizRoot.forDirectory(service);

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(82));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(25),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(57),
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
      expect(vp.packages, hasLength(25));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(25),
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
      expect(vp.packages, hasLength(51));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(20),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(31),
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
      expect(vp.packages, hasLength(20));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(20),
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
      final vp = await VizRoot.forDirectory(service, flagOutdated: true);

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(82));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(25),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(57),
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
      expect(vp.packages, hasLength(82));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(25),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(57),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'ignore', ignoredPackages: ignoredPackages);
    });

    test('workspace', () async {
      final vp = await VizRoot.forDirectory(service, includeWorkspace: true);

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(82));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(1),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(81),
        reason: 'Only non-primary',
      );
    });

    test('update order', () async {
      final vp = await VizRoot.forDirectory(service, flagOutdated: true);
      final updateOrder = computeUpdateOrder(vp);

      expect(updateOrder.map((e) => e.name), [
        'front_end',
        'analyzer',
        'build_resolvers',
        'json_serializable',
        'pana',
      ]);
    });

    test('update order handles a cycle', () {
      final pkgA = VizPackage('a', Version(1, 0, 0), {
        Dependency('b', 'any', false)..includesLatest = false,
      }, Version(2, 0, 0));

      final pkgB = VizPackage('b', Version(1, 0, 0), {
        Dependency('a', 'any', false)..includesLatest = false,
      }, Version(2, 0, 0));

      final root = _MockVizRoot({
        'root': VizPackage('root', Version(1, 0, 0), {}, Version(1, 0, 0)),
        'a': pkgA,
        'b': pkgB,
      });

      final updateOrder = computeUpdateOrder(root);

      expect(updateOrder.map((e) => e.name), ['b', 'a']);
    });
  });

  group('generate VizRoot (real workspace)', () {
    late Service service;

    setUpAll(() {
      service = MockDataService(p.join('test', 'mock_workspace'));
    });

    test('workspace', () async {
      final vp = await VizRoot.forDirectory(service, includeWorkspace: true);

      expect(vp.root.name, 'my_workspace');
      expect(vp.packages, hasLength(4));

      final primaryPackages =
          vp.packages.values.where((element) => element.isPrimary);
      expect(
        primaryPackages.map((e) => e.name),
        unorderedEquals(['my_workspace', 'member_a', 'member_b']),
        reason: 'Workspace members should be primary',
      );

      final memberA = vp.packages['member_a']!;
      final argsDep = memberA.dependencies.firstWhere((d) => d.name == 'args');
      expect(
        argsDep.versionConstraint.toString(),
        '^2.0.0',
        reason: 'Should load constraint from member pubspec',
      );

      final nonPrimaryPackages =
          vp.packages.values.where((element) => !element.isPrimary);
      expect(
        nonPrimaryPackages.map((e) => e.name),
        ['args'],
        reason: 'Transitive dependencies should not be primary',
      );
    });
  });
}

class _MockVizRoot implements VizRoot {
  @override
  final String rootPackageName;
  @override
  final Map<String, VizPackage> packages;

  @override
  VizPackage get root => packages[rootPackageName]!;

  _MockVizRoot(this.packages) : rootPackageName = 'root';
}

const _writeOutput = false;

void _verifyDotOutput(
  VizRoot root,
  String name, {
  Iterable<String> ignoredPackages = const [],
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
