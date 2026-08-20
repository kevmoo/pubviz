@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/service.dart';
import 'package:pubviz/src/update_order.dart';
import 'package:test/scaffolding.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'mock_data_service.dart';

final _mockPath = p.join('test', 'mock');

Future<void> _setupMockSandbox() async {
  final pubspecsJson = jsonDecode(
    File(p.join(_mockPath, 'package_pubspecs.json')).readAsStringSync(),
  ) as Map<String, dynamic>;

  final packageDirs = <d.Descriptor>[];
  for (final entry in pubspecsJson.entries) {
    final deps = (entry.value as Map).cast<String, dynamic>();
    final yamlBuffer = StringBuffer('name: ${entry.key}\ndependencies:\n');
    for (final depEntry in deps.entries) {
      yamlBuffer.writeln('  ${depEntry.key}: "${depEntry.value}"');
    }
    packageDirs.add(
      d.dir(entry.key, [d.file('pubspec.yaml', yamlBuffer.toString())]),
    );
  }

  await d.dir('mock', [
    d.file(
      'pubspec.yaml',
      File(p.join(_mockPath, 'pubspec.yaml')).readAsStringSync(),
    ),
    d.file(
      'outdated.json',
      File(p.join(_mockPath, 'outdated.json')).readAsStringSync(),
    ),
    d.dir('.dart_tool', [
      d.file(
        'package_graph.json',
        File(p.join(_mockPath, '.dart_tool', 'package_graph.json'))
            .readAsStringSync(),
      ),
      d.file(
        'package_config.json',
        File(p.join(_mockPath, '.dart_tool', 'package_config.json'))
            .readAsStringSync(),
      ),
    ]),
    d.dir('packages', packageDirs),
  ]).create();
}

void main() {
  group('generate VizRoot', () {
    late Service service;

    setUpAll(() async {
      await _setupMockSandbox();
      service = MockDataService(d.path('mock'));
    });

    test('all dependencies', () async {
      final vp = await service.vizRoot();

      check(vp.root.name).equals('repo_manager');
      _verifyPackageCounts(vp, total: 82, primary: 1, nonPrimary: 81);

      _verifyDotOutput(vp, 'all_deps');
    });

    test('direct dependencies only', () async {
      final vp = await service.vizRoot(directDependenciesOnly: true);

      check(vp.root.name).equals('repo_manager');
      _verifyPackageCounts(vp, total: 25, primary: 1, nonPrimary: 24);

      _verifyDotOutput(vp, 'direct_deps');
    });

    test('prod dependencies only', () async {
      final vp = await service.vizRoot(productionDependenciesOnly: true);

      check(vp.root.name).equals('repo_manager');
      _verifyPackageCounts(vp, total: 51, primary: 1, nonPrimary: 50);

      _verifyDotOutput(vp, 'production_deps');
    });

    test('prod + direct dependencies only', () async {
      final vp = await service.vizRoot(
        directDependenciesOnly: true,
        productionDependenciesOnly: true,
      );

      check(vp.root.name).equals('repo_manager');
      _verifyPackageCounts(vp, total: 20, primary: 1, nonPrimary: 19);

      _verifyDotOutput(vp, 'direct_production_deps');
    });

    test('outdated', () async {
      final vp = await service.vizRoot(flagOutdated: true);

      check(vp.root.name).equals('repo_manager');
      check(vp.packages).length.equals(82);

      check(
        because: 'Only primary',
        vp.packages.values.where((element) => element.isPrimary),
      ).length.equals(1);
      check(
        because: 'Only non-primary',
        vp.packages.values.where((element) => !element.isPrimary),
      ).length.equals(81);

      _verifyDotOutput(vp, 'outdated');
    });

    test('ignore', () async {
      final ignoredPackages = ['markdown', 'shelf', 'build_runner'];
      final vp = await service.vizRoot(
        flagOutdated: true,
        ignorePackages: ignoredPackages,
      );

      check(vp.root.name).equals('repo_manager');
      check(vp.packages).length.equals(82);

      check(
        because: 'Only primary',
        vp.packages.values.where((element) => element.isPrimary),
      ).length.equals(1);
      check(
        because: 'Only non-primary',
        vp.packages.values.where((element) => !element.isPrimary),
      ).length.equals(81);

      _verifyDotOutput(vp, 'ignore', ignoredPackages: ignoredPackages);
    });

    test('workspace', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      check(vp.isWorkspace).isTrue(); // Verify it starts as true
      check(vp.root.name).equals('repo_manager');
      _verifyPackageCounts(vp, total: 82, primary: 1, nonPrimary: 81);

      // Regression test: filter should preserve isWorkspace
      final filtered = vp.filter(excludeDev: true);
      check(filtered.isWorkspace).isTrue();
    });

    test('update order', () async {
      final vp = await service.vizRoot(flagOutdated: true);
      final updateOrder = computeUpdateOrder(vp);

      check(updateOrder.map((e) => e.name)).deepEquals([
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

      check(updateOrder.map((e) => e.name)).deepEquals(['b', 'a']);
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

      check(filtered.rootPackageName).equals('repo_manager');
      // Should have fewer packages than vp (82) since dev packages are dropped
      check(filtered.packages.length).isLessThan(vp.packages.length);
      check(
        because: 'Only primary',
        filtered.packages.values.where((p) => p.isPrimary),
      ).length.equals(1);

      // Ensure no packages have devDependencies left!
      for (final p in filtered.packages.values) {
        for (final d in p.dependencies) {
          check(d.isDevDependency).isFalse();
        }
      }
    });

    test('onlyOutdated', () {
      final filtered = vp.filter(onlyOutdated: true);

      check(filtered.rootPackageName).equals('repo_manager');
      check(filtered.packages.length).isLessThan(vp.packages.length);

      // Any remaining leaf node without outgoing edges must be an outdated
      // package, unless it is part of the path to an outdated package.
      check(
        because: 'Should contain at least one outdated package',
        filtered.packages.values.any(
          (p) =>
              p.latestVersion != null &&
              p.latestVersion!.compareTo(p.version!) > 0,
        ),
      ).isTrue();
    });

    test('excludeDev and onlyOutdated', () {
      final filtered = vp.filter(excludeDev: true, onlyOutdated: true);

      check(filtered.rootPackageName).equals('repo_manager');
      check(filtered.packages.length).isLessThan(vp.packages.length);

      for (final p in filtered.packages.values) {
        for (final d in p.dependencies) {
          check(d.isDevDependency).isFalse();
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
      check(initialDep.includesLatest).equals(false);

      final filtered = root.filter();
      final filteredDep = filtered.packages['bar']!.dependencies.first;
      check(filteredDep.includesLatest).equals(false);
    });

    test('filter preserves onlyDev state', () {
      final pkg = VizPackage('a', Version(1, 0, 0), {}, null, onlyDev: false);

      final root = VizRoot('a', {'a': pkg});

      final filtered = root.filter(excludeDev: true);
      check(filtered.packages['a']!.onlyDev).isFalse();
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

      check(filtered.packages.keys).unorderedEquals(['a', 'b', 'c']);
      check(filtered.packages.containsKey('d')).isFalse();
    });

    test('hideIsolated hides isolated unpublished and root nodes', () {
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

      final filtered = root.filter(hideIsolated: true);

      // 'a' (root) is primary, so it is kept.
      // 'b' (unpublished) has no incoming dependencies and is not primary,
      // so it is hidden.
      // 'c' is kept because 'a' depends on it.
      check(filtered.packages.keys).unorderedEquals(['a', 'c']);
      check(filtered.packages.containsKey('a')).isTrue();
      check(filtered.packages.containsKey('b')).isFalse();

      // Fallback logic should preserve the root name even if missing from
      // packages
      check(filtered.rootPackageName).equals('a');
      check(filtered.root.name).equals('a');
    });

    test('hideIsolated is ignored in non-workspace context', () {
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

      final filtered = root.filter(hideIsolated: true);

      check(filtered.packages.keys).unorderedEquals(['a', 'b', 'c']);
    });

    test('hideIsolated does not hide primary packages', () {
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

      final filtered = root.filter(hideIsolated: true);

      check(filtered.packages.keys).unorderedEquals(['a']);
    });

    test('hideIsolated removes floating disconnected nodes', () {
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

      final filtered = root.filter(hideIsolated: true);

      check(filtered.packages.keys).unorderedEquals(['root']);
    });

    test('hideIsolated removes edges to ghost nodes', () {
      final a = VizPackage(
        'a',
        Version(1, 0, 0),
        {Dependency('b', VersionConstraint.any, false)},
        null,
        isPrimary: true,
      );

      // We do NOT include 'b' in the sourcePackages map!
      // This simulates 'b' being filtered out previously.

      final root = VizRoot.assemble('a', {'a': a}, isWorkspace: true);

      final filtered = root.filter(hideIsolated: true);

      // 'a' is kept.
      // 'b' is not in sourcePackages, so it should NOT be in 'a's
      // dependencies after filtering!
      final filteredA = filtered.packages['a']!;
      check(filteredA.dependencies.any((d) => d.name == 'b')).isFalse();
    });

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
      check(filtered.packages.keys).unorderedEquals(['a', 'b']);
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
      check(filtered.packages['a']!.isPublishToNone).isTrue();
    });
  });

  group('generate VizRoot (real workspace)', () {
    late Service service;

    setUpAll(() async {
      await d.dir('mock_workspace', [
        d.file('pubspec.yaml', '''
name: my_workspace
environment:
  sdk: '>=3.0.0 <4.0.0'
workspace:
  - member_a
  - member_b
'''),
        d.dir('member_a', [
          d.file('pubspec.yaml', '''
name: member_a
environment:
  sdk: '>=3.0.0 <4.0.0'
resolution: workspace
dependencies:
  args: ^2.0.0
dev_dependencies:
  path: ^1.8.0
'''),
        ]),
        d.dir('member_b', [
          d.file('pubspec.yaml', '''
name: member_b
environment:
  sdk: '>=3.0.0 <4.0.0'
resolution: workspace
dependencies:
  member_a: any
'''),
        ]),
        d.dir('.dart_tool', [
          d.file('package_graph.json', '''
{
  "roots": ["my_workspace", "member_a", "member_b"],
  "packages": [
    {
      "name": "my_workspace",
      "version": "0.0.0",
      "dependencies": []
    },
    {
      "name": "member_a",
      "version": "1.0.0",
      "dependencies": ["args"],
      "devDependencies": ["path"]
    },
    {
      "name": "member_b",
      "version": "1.0.0",
      "dependencies": ["member_a"]
    },
    {
      "name": "args",
      "version": "2.5.0",
      "dependencies": []
    },
    {
      "name": "path",
      "version": "1.9.0",
      "dependencies": []
    }
  ]
}
'''),
          d.file('package_config.json', '''
{
  "configVersion": 2,
  "packages": [
    {"name": "my_workspace", "rootUri": "../", "packageUri": "lib/"},
    {"name": "member_a", "rootUri": "../member_a", "packageUri": "lib/"},
    {"name": "member_b", "rootUri": "../member_b", "packageUri": "lib/"},
    {"name": "args", "rootUri": "file:///fake/args", "packageUri": "lib/"},
    {"name": "path", "rootUri": "file:///fake/path", "packageUri": "lib/"}
  ]
}
'''),
        ]),
      ]).create();
      service = MockDataService(d.path('mock_workspace'));
    });

    test('workspace', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      check(vp.root.name).equals('my_workspace');
      check(vp.packages).length.equals(5);

      final primaryPackages = vp.packages.values.where(
        (element) => element.isPrimary,
      );
      check(
        because: 'Workspace members should be primary',
        primaryPackages.map((e) => e.name),
      ).unorderedEquals(['my_workspace', 'member_a', 'member_b']);

      final memberA = vp.packages['member_a']!;
      final argsDep = memberA.dependencies.firstWhere((d) => d.name == 'args');
      check(
        because: 'Should load constraint from member pubspec',
        argsDep.versionConstraint.toString(),
      ).equals('^2.0.0');

      final nonPrimaryPackages = vp.packages.values.where(
        (element) => !element.isPrimary,
      );
      check(
        because: 'Transitive dependencies should not be primary',
        nonPrimaryPackages.map((e) => e.name),
      ).unorderedEquals(['args', 'path']);
    });

    test('workspace filtering includes all primary packages', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      final filtered = vp.filter(excludeDev: true);

      check(
        because: 'Filtering should retain all workspace primary packages',
        filtered.packages.values.where((p) => p.isPrimary).map((e) => e.name),
      ).unorderedEquals(['my_workspace', 'member_a', 'member_b']);
      check(filtered.packages.containsKey('args')).isTrue();
    });

    test('workspace primary package dev dependencies emit dot edges', () async {
      final vp = await service.vizRoot(includeWorkspace: true);

      // Verify that the dev dependency (path) from member_a is present in the
      // graph and it outputs a dashed edge.
      final dot = vp.toDot();
      check(
        because: 'Dev dependencies of non-root primary packages should render',
        dot,
      ).contains('member_a -> path [label="^1.8.0", style=dashed];');
    });
  });

  group('ahead of latest', () {
    late Service service;

    Future<void> createAheadProject(
      String projectName,
      String constraint,
    ) async {
      await d.dir('${projectName}_test_', [
        d.file('pubspec.yaml', '''
name: $projectName
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  args: $constraint
'''),
        d.dir('.dart_tool', [
          d.file('package_graph.json', '''
{
  "roots": ["$projectName"],
  "packages": [
    {
      "name": "$projectName",
      "version": "1.0.0",
      "dependencies": ["args"]
    },
    {
      "name": "args",
      "version": "2.0.0",
      "dependencies": []
    }
  ]
}
'''),
          d.file('package_config.json', '''
{
  "configVersion": 2,
  "packages": [
    {"name": "$projectName", "rootUri": "../", "packageUri": "lib/"},
    {"name": "args", "rootUri": "file:///fake/args", "packageUri": "lib/"}
  ]
}
'''),
        ]),
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
    }

    setUpAll(() async {
      await createAheadProject('pubviz_ahead', '^2.0.0-dev');
      service = MockDataService(d.path('pubviz_ahead_test_'));
    });

    test('allowsLatest is true for ahead constraints', () async {
      final vp = await service.vizRoot(flagOutdated: true);

      final root = vp.root;
      check(root.name).equals('pubviz_ahead');

      final dep = root.dependencies.firstWhere((d) => d.name == 'args');
      check(
        because: 'Constraint ^2.0.0-dev is a pre-release ahead of latest 1.5.0',
        dep.includesLatest,
      ).equals(true);
    });

    test('allowsLatest is false for stable ahead constraints', () async {
      await createAheadProject('pubviz_ahead_stable', '^2.0.0');

      final stableService = MockDataService(
        d.path('pubviz_ahead_stable_test_'),
      );
      final vp = await stableService.vizRoot(flagOutdated: true);
      final dep = vp.root.dependencies.firstWhere((d) => d.name == 'args');
      check(
        because: 'Stable constraint ^2.0.0 shouldn\'t allow latest 1.5.0',
        dep.includesLatest,
      ).equals(false);
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
      check(
        because: 'onlyDev should remain false after roundtrip',
        pkg2.onlyDev,
      ).isFalse();
    });
  });
}

class _MockVizRoot with HasPackages implements VizRoot {
  @override
  VizRoot filter({
    bool excludeDev = false,
    bool onlyOutdated = false,
    bool onlyWorkspace = false,
    bool hideIsolated = false,
    Iterable<String> ignorePackages = const [],
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

void _verifyPackageCounts(
  VizRoot root, {
  required int total,
  required int primary,
  required int nonPrimary,
}) {
  check(root.packages).length.equals(total);

  check(
    because: 'Only primary',
    root.packages.values.where((element) => element.isPrimary),
  ).length.equals(primary);
  check(
    because: 'Only non-primary',
    root.packages.values.where((element) => !element.isPrimary),
  ).length.equals(nonPrimary);
}

void _verifyDotOutput(
  VizRoot root,
  String name, {
  Iterable<String> ignoredPackages = const [],
}) {
  final dotOutput = root.toDot(ignorePackages: ignoredPackages);

  final filePath = p.join(_mockPath, '$name.dot');

  if (_writeOutput) {
    File(filePath).writeAsStringSync(dotOutput);
    throw StateError('Set `_writeOutput` to false!');
  }

  printOnFailure(dotOutput);

  final fileContent = File(filePath).readAsStringSync();

  check(dotOutput).equals(fileContent);
}
