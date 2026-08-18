import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as parse;
import 'package:pubviz/src/converters.dart';
import 'package:pubviz/src/dependency.dart';
import 'package:pubviz/src/deps_list.dart';
import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/root_builder.dart';
import 'package:pubviz/src/service.dart';
import 'package:pubviz/src/viz_package.dart';
import 'package:pubviz/src/viz_root.dart';
import 'package:test/scaffolding.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('converters', () {
    test('FalseNullConverter', () {
      const converter = FalseNullConverter();
      check(converter.fromJson(null)).isFalse();
      check(converter.fromJson(true)).isTrue();
      check(converter.fromJson(false)).isFalse();
      check(converter.toJson(true)).equals(true);
      check(converter.toJson(false)).isNull();
    });

    test('VersionConverter', () {
      const converter = VersionConverter();
      check(converter.fromJson(null)).isNull();
      check(converter.fromJson('1.0.0')).equals(Version(1, 0, 0));
      check(converter.toJson(Version(1, 0, 0))).equals('1.0.0');
      check(converter.toJson(null)).isNull();
    });

    test('VersionConstraintConverter', () {
      const converter = VersionConstraintConverter();
      check(converter.fromJson('^1.0.0'))
          .equals(VersionConstraint.parse('^1.0.0'));
      check(converter.fromJson('bad')).equals(VersionConstraint.empty);
      check(converter.toJson(VersionConstraint.parse('^1.0.0')))
          .equals('^1.0.0');
    });
  });

  group('Dependency', () {
    test('equality and hashCode', () {
      final d1 = Dependency('a', VersionConstraint.any, false);
      final d2 = Dependency('a', VersionConstraint.parse('^1.0.0'), true);
      final d3 = Dependency('b', VersionConstraint.any, false);

      check(d1).equals(d2);
      check(d1.hashCode).equals(d2.hashCode);
      check(d1).not((it) => it.equals(d3));
    });

    test('compareTo', () {
      final da1 = Dependency('a', VersionConstraint.any, false);
      final da2 = Dependency('a', VersionConstraint.any, true);
      final db1 = Dependency('b', VersionConstraint.any, false);

      check(da1.compareTo(db1)).isLessThan(0);
      check(db1.compareTo(da1)).isGreaterThan(0);
      check(da1.compareTo(da2)).isLessThan(0);
      check(da2.compareTo(da1)).isGreaterThan(0);
      check(da1.compareTo(da1)).equals(0);
    });

    test('toString', () {
      check(
        Dependency('a', VersionConstraint.parse('^1.0.0'), false).toString(),
      ).equals('a ^1.0.0');
      check(Dependency('a', VersionConstraint.parse('^1.0.0'), true).toString())
          .equals('a(dev) ^1.0.0');
    });

    test('json', () {
      final dep = Dependency('a', VersionConstraint.parse('^1.0.0'), true);
      final json = dep.toJson();
      check(json['name']).equals('a');
      check(json['versionConstraint']).equals('^1.0.0');
      check(json['isDevDependency']).equals(true);

      final dep2 = Dependency.fromJson(json);
      check(dep2.name).equals(dep.name);
      check(dep2.versionConstraint).equals(dep.versionConstraint);
      check(dep2.isDevDependency).equals(dep.isDevDependency);
    });
  });

  group('VizPackage', () {
    test('equality and hashCode', () {
      final p1 = VizPackage('a', Version(1, 0, 0), {}, null);
      final p2 = VizPackage('a', Version(1, 0, 0), {}, null);
      final p3 = VizPackage('b', Version(1, 0, 0), {}, null);

      check(p1).equals(p2);
      check(p1.hashCode).equals(p2.hashCode);
      check(p1).not((it) => it.equals(p3));
    });

    test('compareTo', () {
      final p1 = VizPackage('a', Version(1, 0, 0), {}, null);
      final p2 = VizPackage('b', Version(1, 0, 0), {}, null);

      check(p1.compareTo(p2)).isLessThan(0);
      check(p2.compareTo(p1)).isGreaterThan(0);
    });

    test('toString', () {
      check(VizPackage('a', Version(1, 0, 0), {}, null).toString())
          .equals('a @ 1.0.0');
    });

    test('json', () {
      final pkg = VizPackage(
        'a',
        Version(1, 0, 0),
        {Dependency('b', VersionConstraint.any, false)},
        Version(1, 1, 0),
        isPrimary: true,
      );
      final json = pkg.toJson();
      check(json['name']).equals('a');
      check(json['version']).equals('1.0.0');
      check(json['latestVersion']).equals('1.1.0');
      check(json['isPrimary']).equals(true);

      // Manually handle the fact that explicitToJson is false
      final fullJson = jsonDecode(jsonEncode(pkg)) as Map<String, dynamic>;
      final pkg2 = VizPackage.fromJson(fullJson);
      check(pkg2.name).equals(pkg.name);
      check(pkg2.version).equals(pkg.version);
      check(pkg2.latestVersion).equals(pkg.latestVersion);
      check(pkg2.isPrimary).equals(pkg.isPrimary);

      check(pkg2.dependencies).length.equals(1);
      final dep = pkg2.dependencies.first;
      check(dep.name).equals('b');
      check(dep.versionConstraint).equals(VersionConstraint.any);
      check(dep.isDevDependency).isFalse();
    });
  });

  group('VizRoot', () {
    test('json', () {
      final root = VizRoot('a', {
        'a': VizPackage('a', Version(1, 0, 0), {}, null),
      });
      final json = root.toJson();
      check(json['rootPackageName']).equals('a');

      final fullJson = jsonDecode(jsonEncode(root)) as Map<String, dynamic>;
      final root2 = VizRoot.fromJson(fullJson);
      check(root2.rootPackageName).equals(root.rootPackageName);
      check(root2.packages.keys).contains('a');
    });

    test('filter workspace with excludeDev', () {
      final root = VizRoot.assemble('a', {
        'a': VizPackage('a', Version(1, 0, 0), {
          Dependency('b', VersionConstraint.any, false),
          Dependency('c', VersionConstraint.any, true),
        }, null),
        'b': VizPackage('b', Version(1, 0, 0), {
          Dependency('a', VersionConstraint.any, false),
        }, null),
        'c': VizPackage('c', Version(1, 0, 0), {
          Dependency('a', VersionConstraint.any, false),
        }, null),
      });

      final filtered = root.filter(onlyWorkspace: true, excludeDev: true);
      check(filtered.packages.keys).contains('a');
      check(filtered.packages.keys).contains('b');
      check(filtered.packages.keys).not((it) => it.contains('c'));
    });

    test('filter with ignorePackages', () {
      final root = VizRoot.assemble('a', {
        'a': VizPackage('a', Version(1, 0, 0), {
          Dependency('b', VersionConstraint.any, false),
          Dependency('c', VersionConstraint.any, false),
        }, null),
        'b': VizPackage('b', Version(1, 0, 0), {
          Dependency('d', VersionConstraint.any, false),
        }, null),
        'c': VizPackage('c', Version(1, 0, 0), {}, null),
        'd': VizPackage('d', Version(1, 0, 0), {}, null),
      });

      final filtered = root.filter(ignorePackages: ['b']);
      check(filtered.packages.keys).unorderedEquals(['a', 'c']);
      check(filtered.packages['a']!.dependencies.map((d) => d.name))
          .unorderedEquals(['c']);
    });

    test('Dependency.getDependencies', () {
      final pubspec = parse.Pubspec.parse('''
name: foo
dependencies:
  bar: ^1.0.0
  baz:
    path: ../baz
dev_dependencies:
  qux: '>=1.0.0 <2.0.0'
''');
      final deps = Dependency.getDependencies(pubspec);
      check(deps.map((d) => d.name))
        ..contains('bar')
        ..contains('baz')
        ..contains('qux');

      final bar = deps.firstWhere((d) => d.name == 'bar');
      check(bar.versionConstraint.toString()).equals('^1.0.0');
      check(bar.isDevDependency).isFalse();

      final baz = deps.firstWhere((d) => d.name == 'baz');
      // PathDependency.toString() is "path: ../baz", which is not a valid version constraint.
      check(baz.versionConstraint).equals(VersionConstraint.empty);
      check(baz.isDevDependency).isFalse();

      final qux = deps.firstWhere((d) => d.name == 'qux');
      check(qux.isDevDependency).isTrue();
    });
  });

  group('options', () {
    test('parser getter', () {
      check(parser).isNotNull();
    });
  });

  group('Service', () {
    test('vizRoot orElse throw StateError', () async {
      final service = _SimpleMockService();
      // 'c' is a dependency of 'b', but 'c' is not in allDeps
      await check(service.vizRoot()).throws<StateError>(
        (it) => it
            .has((e) => e.message, 'message')
            .contains('Could not find an entry for `c`'),
      );
    });

    test('vizRoot workspace with outdated', testOn: 'vm', () async {
      await d.dir('fake_pkg', [
        d.file('pubspec.yaml', 'name: a'),
        d.dir('member', [d.file('pubspec.yaml', 'name: member')]),
      ]).create();

      final service = _WorkspaceMockService(d.path('fake_pkg'));
      final root = await service.vizRoot(
        includeWorkspace: true,
        flagOutdated: true,
      );
      check(root.packages['member'])
          .isNotNull()
          .has((p) => p.latestVersion, 'latestVersion')
          .equals(Version(1, 1, 0));
    });
  });
}

class _WorkspaceMockService extends Service {
  @override
  final String rootPackageDir;

  _WorkspaceMockService(this.rootPackageDir);

  @override
  parse.Pubspec rootPubspec() => parse.Pubspec.parse(
    'name: a',
    sourceUrl: Uri.file(p.join(rootPackageDir, 'pubspec.yaml')),
  );

  @override
  DepsPackageEntry rootDeps() => DepsList.fromJson(const {
    'root': 'a',
    'packages': [
      {
        'name': 'a',
        'version': '1.0.0',
        'kind': 'root',
        'source': 'root',
        'dependencies': ['member'],
        'directDependencies': ['member'],
        'devDependencies': <String>[],
        'dependencyConstraints': {'member': '1.0.0'},
      },
      {
        'name': 'member',
        'version': '1.0.0',
        'kind': 'root',
        'source': 'root',
        'dependencies': <String>[],
        'directDependencies': <String>[],
        'devDependencies': <String>[],
        'dependencyConstraints': <String, String>{},
      },
    ],
    'sdks': [
      {'name': 'Dart', 'version': '3.13.0'},
    ],
    'executables': <String>[],
  }).packages['a']!;

  @override
  Iterable<DepsPackageEntry> allDeps() {
    final list = DepsList.fromJson(const {
      'root': 'a',
      'packages': [
        {
          'name': 'a',
          'version': '1.0.0',
          'kind': 'root',
          'source': 'root',
          'dependencies': ['member'],
          'directDependencies': ['member'],
          'devDependencies': <String>[],
          'dependencyConstraints': {'member': '1.0.0'},
        },
        {
          'name': 'member',
          'version': '1.0.0',
          'kind': 'root',
          'source': 'root',
          'dependencies': <String>[],
          'directDependencies': <String>[],
          'devDependencies': <String>[],
          'dependencyConstraints': <String, String>{},
        },
      ],
      'sdks': [
        {'name': 'Dart', 'version': '3.13.0'},
      ],
      'executables': <String>[],
    });
    return list.packages.values;
  }

  @override
  Future<Map<String, String>> workspaceMembers() async => {
    'a': '.',
    'member': 'member',
  };

  @override
  Map<String, dynamic> outdated() => {
    'packages': [
      {
        'package': 'member',
        'current': {'version': '1.0.0'},
        'latest': {'version': '1.1.0'},
      },
    ],
  };
}

class _SimpleMockService extends Service {
  late final _depsList = DepsList.fromJson(const {
    'root': 'a',
    'packages': [
      {
        'name': 'a',
        'version': '1.0.0',
        'kind': 'root',
        'source': 'root',
        'dependencies': ['b'],
        'directDependencies': ['b'],
        'devDependencies': <String>[],
        'dependencyConstraints': {'b': '1.0.0'},
      },
      {
        'name': 'b',
        'version': '1.0.0',
        'kind': 'direct',
        'source': 'hosted',
        'dependencies': ['c'],
        'directDependencies': ['c'],
        'devDependencies': <String>[],
        'dependencyConstraints': {'c': '^1.0.0'},
      },
    ],
    'sdks': [
      {'name': 'Dart', 'version': '3.13.0'},
    ],
    'executables': <String>[],
  });

  @override
  String get rootPackageDir => 'fake';

  @override
  parse.Pubspec rootPubspec() => parse.Pubspec.parse('name: a');

  @override
  DepsPackageEntry rootDeps() => _depsList.packages['a']!;

  @override
  Iterable<DepsPackageEntry> allDeps() => _depsList.packages.values;

  @override
  Future<Map<String, String>> workspaceMembers() async => {'a': '.'};

  @override
  Map<String, dynamic> outdated() => {'packages': <void>[]};
}
