@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/pubviz.dart';

import 'package:pubviz/src/service.dart';
import 'package:pubviz/src/update_order.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'mock_data_service.dart';

final _mockPath = p.join('test', 'mock');

void main() {
  group('generate VizRoot', () {
    late Service service;

    setUpAll(() {
      service = MockDataService(_mockPath);
    });

    test('all dependencies', () async {
      final vp = await service.vizRoot();

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

      _verifyDotOutput(vp, 'all_deps');
    });

    test('direct dependencies only', () async {
      final vp = await service.vizRoot(directDependenciesOnly: true);

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(25));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(1),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(24),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'direct_deps');
    });

    test('prod dependencies only', () async {
      final vp = await service.vizRoot(productionDependenciesOnly: true);

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(51));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(1),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(50),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'production_deps');
    });

    test('prod + direct dependencies only', () async {
      final vp = await service.vizRoot(
        directDependenciesOnly: true,
        productionDependenciesOnly: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.packages, hasLength(20));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(1),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(19),
        reason: 'Only non-primary',
      );

      _verifyDotOutput(vp, 'direct_production_deps');
    });

    test('outdated', () async {
      final vp = await service.vizRoot(flagOutdated: true);

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

      _verifyDotOutput(vp, 'outdated');
    });

    test('ignore', () async {
      final ignoredPackages = ['markdown', 'shelf', 'build_runner'];
      final vp = await service.vizRoot(
        flagOutdated: true,
        ignorePackages: ignoredPackages,
      );

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

      _verifyDotOutput(vp, 'ignore', ignoredPackages: ignoredPackages);
    });

    test('workspace', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      expect(vp.isWorkspace, isTrue); // Verify it starts as true
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

      // Regression test: filter should preserve isWorkspace
      final filtered = vp.filter(excludeDev: true);
      expect(filtered.isWorkspace, isTrue);
    });

    test('update order', () async {
      final vp = await service.vizRoot(flagOutdated: true);
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
        Dependency('b', VersionConstraint.any, false, includesLatest: false),
      }, Version(2, 0, 0));

      final pkgB = VizPackage('b', Version(1, 0, 0), {
        Dependency('a', VersionConstraint.any, false, includesLatest: false),
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

  group('filter', () {
    late Service service;
    late VizRoot vp;

    setUpAll(() async {
      service = MockDataService(_mockPath);
      vp = await service.vizRoot(flagOutdated: true);
    });

    test('excludeDev', () {
      final filtered = vp.filter(excludeDev: true);

      expect(filtered.rootPackageName, 'repo_manager');
      // Should have fewer packages than vp (82) since dev packages are dropped
      expect(filtered.packages.length, lessThan(vp.packages.length));
      expect(
        filtered.packages.values.where((p) => p.isPrimary),
        hasLength(1),
        reason: 'Only primary',
      );

      // Ensure no packages have devDependencies left!
      for (final p in filtered.packages.values) {
        for (final d in p.dependencies) {
          expect(d.isDevDependency, isFalse);
        }
      }
    });

    test('onlyOutdated', () {
      final filtered = vp.filter(onlyOutdated: true);

      expect(filtered.rootPackageName, 'repo_manager');
      expect(filtered.packages.length, lessThan(vp.packages.length));

      // Any remaining leaf node without outgoing edges must be an outdated
      // package, unless it is part of the path to an outdated package.
      expect(
        filtered.packages.values.any(
          (p) =>
              p.latestVersion != null &&
              p.latestVersion!.compareTo(p.version!) > 0,
        ),
        isTrue,
        reason: 'Should contain at least one outdated package',
      );
    });

    test('excludeDev and onlyOutdated', () {
      final filtered = vp.filter(excludeDev: true, onlyOutdated: true);

      expect(filtered.rootPackageName, 'repo_manager');
      expect(filtered.packages.length, lessThan(vp.packages.length));

      for (final p in filtered.packages.values) {
        for (final d in p.dependencies) {
          expect(d.isDevDependency, isFalse);
        }
      }
    });
    test('preserves includesLatest calculation', () {
      final dep = Dependency(
        'foo',
        VersionConstraint.parse('>=1.0.0 <1.2.0'),
        false,
      );
      final pkg = VizPackage(
        'bar',
        Version(1, 0, 0),
        {dep},
        null,
        isPrimary: true,
      );
      final depPkg = VizPackage('foo', Version(1, 1, 0), {}, Version(1, 3, 0));

      final root = VizRoot.assemble('bar', {
        'bar': pkg,
        'foo': depPkg,
      }, flagOutdated: true);

      final initialDep = root.packages['bar']!.dependencies.first;
      expect(initialDep.includesLatest, isFalse);

      final filtered = root.filter();
      final filteredDep = filtered.packages['bar']!.dependencies.first;
      expect(filteredDep.includesLatest, isFalse);
    });

    test('filter preserves onlyDev state', () {
      final pkg = VizPackage('a', Version(1, 0, 0), {}, null, onlyDev: false);

      final root = VizRoot('a', {'a': pkg});

      final filtered = root.filter(excludeDev: true);
      expect(filtered.packages['a']!.onlyDev, isFalse);
    });

    test('onlyWorkspace retains bridges', () {
      final a = VizPackage(
        'a',
        Version(1, 0, 0),
        {Dependency('b', VersionConstraint.any, false)},
        null,
        isPrimary: true,
      );

      final b = VizPackage('b', Version(1, 0, 0), {
        Dependency('c', VersionConstraint.any, false),
      }, null);

      final c = VizPackage('c', Version(1, 0, 0), {}, null, isPrimary: true);

      final d = VizPackage('d', Version(1, 0, 0), {}, null);

      final root = VizRoot.assemble('a', {
        'a': a,
        'b': b,
        'c': c,
        'd': d,
      }, isWorkspace: true);

      final filtered = root.filter(onlyWorkspace: true);

      expect(filtered.packages.keys, unorderedEquals(['a', 'b', 'c']));
      expect(filtered.packages.containsKey('d'), isFalse);
    });

    test(
      'hideIsolatedWorkspacePackages hides isolated unpublished and root nodes',
      () {
        final a = VizPackage(
          'a',
          Version(1, 0, 0),
          {Dependency('c', VersionConstraint.any, false)},
          null,
          isPrimary: true,
        );

        final b = VizPackage(
          'b',
          Version(1, 0, 0),
          {},
          null,
          isPrimary: true,
          isPublishToNone: true,
        );

        final c = VizPackage('c', Version(1, 0, 0), {}, null);

        final root = VizRoot.assemble('a', {
          'a': a,
          'b': b,
          'c': c,
        }, isWorkspace: true);

        final filtered = root.filter(hideIsolatedWorkspacePackages: true);

        // 'a' (root) is primary, so it is kept.
        // 'b' (unpublished) has no incoming dependencies and is not primary,
        // so it is hidden.
        // 'c' is kept because 'a' depends on it.
        expect(filtered.packages.keys, unorderedEquals(['a', 'c']));
        expect(filtered.packages.containsKey('a'), isTrue);
        expect(filtered.packages.containsKey('b'), isFalse);

        // Fallback logic should preserve the root name even if missing from
        // packages
        expect(filtered.rootPackageName, equals('a'));
        expect(filtered.root.name, equals('a'));
      },
    );

    test(
      'hideIsolatedWorkspacePackages is ignored in non-workspace context',
      () {
        final a = VizPackage(
          'a',
          Version(1, 0, 0),
          {Dependency('c', VersionConstraint.any, false)},
          null,
          isPrimary: true,
        );

        final b = VizPackage(
          'b',
          Version(1, 0, 0),
          {},
          null,
          isPrimary: true,
          isPublishToNone: true,
        );

        final c = VizPackage('c', Version(1, 0, 0), {}, null);

        final root = VizRoot.assemble('a', {'a': a, 'b': b, 'c': c});

        final filtered = root.filter(hideIsolatedWorkspacePackages: true);

        expect(filtered.packages.keys, unorderedEquals(['a', 'b', 'c']));
      },
    );

    test('hideIsolatedWorkspacePackages does not hide primary packages', () {
      final a = VizPackage(
        'a',
        Version(1, 0, 0),
        {},
        null,
        isPrimary: true,
        isPublishToNone: true,
      );

      final b = VizPackage(
        'b',
        Version(1, 0, 0),
        {},
        null,
        isPublishToNone: true,
      );

      final root = VizRoot.assemble('a', {'a': a, 'b': b}, isWorkspace: true);

      final filtered = root.filter(hideIsolatedWorkspacePackages: true);

      expect(filtered.packages.keys, unorderedEquals(['a']));
    });

    test(
      'hideIsolatedWorkspacePackages removes floating disconnected nodes',
      () {
        final a = VizPackage(
          'a',
          Version(1, 0, 0),
          {Dependency('b', VersionConstraint.any, false)},
          null,
          isPublishToNone: true,
        );

        final b = VizPackage(
          'b',
          Version(1, 0, 0),
          {},
          null,
          isPublishToNone: true,
        );

        final rootPkg = VizPackage(
          'root',
          Version(1, 0, 0),
          {},
          null,
          isPrimary: true,
        );

        final root = VizRoot.assemble('root', {
          'root': rootPkg,
          'a': a,
          'b': b,
        }, isWorkspace: true);

        final filtered = root.filter(hideIsolatedWorkspacePackages: true);

        expect(filtered.packages.keys, unorderedEquals(['root']));
      },
    );

    test('onlyWorkspace and onlyOutdated can be combined', () {
      final a = VizPackage(
        'a',
        Version(1, 0, 0),
        {Dependency('b', VersionConstraint.any, false)},
        null,
        isPrimary: true,
      );

      final b = VizPackage('b', Version(1, 0, 0), {
        Dependency('c', VersionConstraint.any, false),
      }, Version(2, 0, 0));

      final c = VizPackage('c', Version(1, 0, 0), {}, null, isPrimary: true);

      final d = VizPackage('d', Version(1, 0, 0), {}, null);

      final root = VizRoot.assemble(
        'a',
        {'a': a, 'b': b, 'c': c, 'd': d},
        isWorkspace: true,
        flagOutdated: true,
      );

      final filtered = root.filter(onlyWorkspace: true, onlyOutdated: true);

      // Should retain 'a' and 'b' (workspace + path to outdated)
      // 'c' is in workspace but not outdated or leading to outdated
      // 'd' is not in workspace
      expect(filtered.packages.keys, unorderedEquals(['a', 'b']));
    });

    test('filter preserves isPublishToNone', () {
      final pkg = VizPackage(
        'a',
        Version(1, 0, 0),
        {},
        null,
        isPublishToNone: true,
      );

      final root = VizRoot('a', {'a': pkg});

      final filtered = root.filter(excludeDev: true);
      expect(filtered.packages['a']!.isPublishToNone, isTrue);
    });
  });

  group('generate VizRoot (real workspace)', () {
    late Service service;

    setUpAll(() {
      service = MockDataService(p.join('test', 'mock_workspace'));
    });

    test('workspace', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      expect(vp.root.name, 'my_workspace');
      expect(vp.packages, hasLength(5));

      final primaryPackages = vp.packages.values.where(
        (element) => element.isPrimary,
      );
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

      final nonPrimaryPackages = vp.packages.values.where(
        (element) => !element.isPrimary,
      );
      expect(
        nonPrimaryPackages.map((e) => e.name),
        unorderedEquals(['args', 'path']),
        reason: 'Transitive dependencies should not be primary',
      );
    });

    test('workspace filtering includes all primary packages', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      final filtered = vp.filter(excludeDev: true);

      expect(
        filtered.packages.values.where((p) => p.isPrimary).map((e) => e.name),
        unorderedEquals(['my_workspace', 'member_a', 'member_b']),
        reason: 'Filtering should retain all workspace primary packages',
      );
      expect(filtered.packages.containsKey('args'), isTrue);
    });

    test('workspace primary package dev dependencies emit dot edges', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      // Verify that the dev dependency (path) from member_a is present in the
      // graph and it outputs a dashed edge.
      final dot = vp.toDot();
      expect(
        dot,
        contains('member_a -> path [label="^1.8.0", style=dashed];'),
        reason: 'Dev dependencies of non-root primary packages should render',
      );
    });
  });

  group('ahead of latest', () {
    late Service service;

    setUpAll(() async {
      await d.dir('pubviz_ahead_test_', [
        d.file('pubspec.yaml', '''
name: test_ahead
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  args: ^2.0.0-dev
'''),
        d.file('pub_deps_list.txt', '''
Dart SDK 3.0.0
test_ahead 1.0.0

dependencies:
- args 2.0.0
'''),
        d.file('outdated.json', '''
{
  "packages": [
    {
      "package": "args",
      "current": { "version": "2.0.0" },
      "upgradable": { "version": "2.0.0" },
      "resolvable": { "version": "2.0.0" },
      "latest": { "version": "1.5.0" }
    }
  ]
}
'''),
      ]).create();

      service = MockDataService(d.path('pubviz_ahead_test_'));
    });

    test('allowsLatest is true for ahead constraints', () async {
      final vp = await service.vizRoot(flagOutdated: true);

      final root = vp.root;
      expect(root.name, 'test_ahead');

      final dep = root.dependencies.firstWhere((d) => d.name == 'args');
      expect(
        dep.includesLatest,
        isTrue,
        reason: 'Constraint ^2.0.0-dev is a pre-release ahead of latest 1.5.0',
      );
    });

    test('allowsLatest is false for stable ahead constraints', () async {
      await d.dir('pubviz_ahead_stable_test_', [
        d.file('pubspec.yaml', '''
name: test_ahead_stable
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  args: ^2.0.0
'''),
        d.file('pub_deps_list.txt', '''
Dart SDK 3.0.0
test_ahead_stable 1.0.0

dependencies:
- args 2.0.0
'''),
        d.file('outdated.json', '''
{
  "packages": [
    {
      "package": "args",
      "current": { "version": "2.0.0" },
      "upgradable": { "version": "2.0.0" },
      "resolvable": { "version": "2.0.0" },
      "latest": { "version": "1.5.0" }
    }
  ]
}
'''),
      ]).create();

      final stableService = MockDataService(
        d.path('pubviz_ahead_stable_test_'),
      );
      final vp = await stableService.vizRoot(flagOutdated: true);
      final dep = vp.root.dependencies.firstWhere((d) => d.name == 'args');
      expect(
        dep.includesLatest,
        isFalse,
        reason: 'Stable constraint ^2.0.0 shouldn\'t allow latest 1.5.0',
      );
    });
  });

  group('VizPackage', () {
    test('onlyDev false roundtrip', () {
      final pkg = VizPackage(
        'test_pkg',
        Version.parse('1.0.0'),
        {},
        Version.parse('1.0.0'),
        onlyDev: false,
      );

      final json = pkg.toJson();
      final pkg2 = VizPackage.fromJson(json);
      expect(
        pkg2.onlyDev,
        isFalse,
        reason: 'onlyDev should remain false after roundtrip',
      );
    });
  });
}

class _MockVizRoot with HasPackages implements VizRoot {
  @override
  VizRoot filter({
    bool excludeDev = false,
    bool onlyOutdated = false,
    bool onlyWorkspace = false,
    bool hideIsolatedWorkspacePackages = false,
  }) => throw UnimplementedError();

  @override
  final String rootPackageName;
  @override
  final Map<String, VizPackage> packages;
  @override
  bool get isWorkspace => false;

  _MockVizRoot(this.packages) : rootPackageName = 'root';

  @override
  Map<String, dynamic> toJson() => {};
}

const _writeOutput = false;

void _verifyDotOutput(
  VizRoot root,
  String name, {
  Iterable<String> ignoredPackages = const [],
}) {
  final dotOutput = root.toDot(ignorePackages: ignoredPackages);

  final filePath = p.join(_mockPath, '$name.dot');

  if (_writeOutput) {
    File(filePath).writeAsStringSync(dotOutput);
    fail('Set `_writeOutput` to false!');
  }

  printOnFailure(dotOutput);

  final fileContent = File(filePath).readAsStringSync();

  expect(dotOutput, fileContent);
}
