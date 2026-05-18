@TestOn('vm')
library;

import 'package:checks/checks.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/deps_list.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('DepsList.fromJson parses pub deps --json format with constraints '
      'correctly', () {
    final jsonMap = <String, dynamic>{
      'root': 'myapp',
      'packages': <dynamic>[
        <String, dynamic>{
          'name': 'myapp',
          'version': '1.0.0',
          'kind': 'root',
          'source': 'root',
          'dependencies': <String>['foo', 'test_dep'],
          'directDependencies': <String>['foo'],
          'devDependencies': <String>['test_dep'],
          'dependencyConstraints': <String, String>{
            'foo': '^2.1.0',
            'test_dep': '^1.0.0',
          },
        },
        <String, dynamic>{
          'name': 'foo',
          'version': '2.3.4',
          'kind': 'direct',
          'source': 'hosted',
          'dependencies': <String>['bar'],
          'directDependencies': <String>['bar'],
          'dependencyConstraints': <String, String>{'bar': '>=1.0.0 <3.0.0'},
        },
        <String, dynamic>{
          'name': 'test_dep',
          'version': '1.5.0',
          'kind': 'dev',
          'source': 'hosted',
          'dependencies': <String>[],
          'directDependencies': <String>[],
          'dependencyConstraints': <String, String>{},
        },
        <String, dynamic>{
          'name': 'bar',
          'version': '1.2.0',
          'kind': 'transitive',
          'source': 'hosted',
          'dependencies': <String>[],
          'directDependencies': <String>[],
          'dependencyConstraints': <String, String>{},
        },
      ],
      'sdks': <dynamic>[
        <String, String>{'name': 'Dart', 'version': '3.13.0'},
      ],
      'executables': <String>[],
    };

    final depsList = DepsList.fromJson(jsonMap);

    check(depsList.rootPackageName).equals('myapp');
    check(depsList.sdks)['Dart'].equals(Version.parse('3.13.0'));

    final rootPkg = depsList.rootPackage;
    check(rootPkg.name).equals('myapp');
    check(rootPkg.version).equals(Version.parse('1.0.0'));

    // Check dependencies section of root package
    check(rootPkg.sections).containsKey('dependencies');
    final depsSection = rootPkg.sections['dependencies']!;
    check(depsSection.keys.map((e) => e.name)).contains('foo');
    check(
      depsSection.keys.map((e) => e.version),
    ).contains(Version.parse('2.3.4'));

    final fooKey = depsSection.keys.firstWhere((e) => e.name == 'foo');
    check(
      depsSection[fooKey]!,
    )['bar'].equals(VersionConstraint.parse('>=1.0.0 <3.0.0'));

    // Check dev dependencies section of root package
    check(rootPkg.sections).containsKey('dev dependencies');
    final devSection = rootPkg.sections['dev dependencies']!;
    check(devSection.keys.map((e) => e.name)).contains('test_dep');

    // Check transitive dependencies
    check(
      depsList.transitiveDependencies.keys.map((e) => e.name),
    ).contains('bar');
    final barKey = depsList.transitiveDependencies.keys.firstWhere(
      (e) => e.name == 'bar',
    );
    check(depsList.transitiveDependencies[barKey]!).isEmpty();

    // Check allEntries
    check(
      rootPkg.allEntries.keys.map((e) => e.name),
    ).unorderedEquals(['foo', 'test_dep', 'bar']);
  });

  test('DepsList.fromJson handles workspace with multiple roots', () {
    final jsonMap = <String, dynamic>{
      'root': 'workspace_root',
      'packages': <dynamic>[
        <String, dynamic>{
          'name': 'workspace_root',
          'version': '0.0.0',
          'kind': 'root',
          'source': 'root',
          'dependencies': <String>['member_a'],
          'directDependencies': <String>['member_a'],
          'devDependencies': <String>[],
          'dependencyConstraints': <String, String>{'member_a': '0.0.0'},
        },
        <String, dynamic>{
          'name': 'member_a',
          'version': '1.0.0',
          'kind': 'root',
          'source': 'root',
          'dependencies': <String>['args'],
          'directDependencies': <String>['args'],
          'devDependencies': <String>[],
          'dependencyConstraints': <String, String>{'args': '^2.0.0'},
        },
        <String, dynamic>{
          'name': 'args',
          'version': '2.4.2',
          'kind': 'direct',
          'source': 'hosted',
          'dependencies': <String>[],
          'directDependencies': <String>[],
          'dependencyConstraints': <String, String>{},
        },
      ],
      'sdks': <dynamic>[
        <String, String>{'name': 'Dart', 'version': '3.13.0'},
      ],
      'executables': <String>[],
    };

    final depsList = DepsList.fromJson(jsonMap);
    check(
      depsList.packages.keys,
    ).unorderedEquals(['workspace_root', 'member_a']);
    check(depsList.rootPackage.name).equals('workspace_root');

    final memberA = depsList.packages['member_a']!;
    check(memberA.sections).containsKey('dependencies');
    final argsKey = memberA.sections['dependencies']!.keys.first;
    check(argsKey.name).equals('args');
    check(argsKey.version).equals(Version.parse('2.4.2'));
  });
}
