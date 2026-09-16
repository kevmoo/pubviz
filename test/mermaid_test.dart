import 'package:checks/checks.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/dependency.dart';
import 'package:pubviz/src/mermaid.dart';
import 'package:pubviz/src/viz_package.dart';
import 'package:pubviz/src/viz_root.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('toMermaid formats diagram correctly', () {
    final root = VizRoot('a', {
      'a': VizPackage(
        'a',
        Version(1, 0, 0),
        {
          Dependency('b', VersionConstraint.parse('^1.0.0'), false),
          Dependency('c', VersionConstraint.any, true),
        },
        null,
        isPrimary: true,
        onlyDev: false,
      ),
      'b': VizPackage(
        'b',
        Version(1, 2, 0),
        {},
        Version(1, 3, 0),
        onlyDev: false,
      ), // outdated
      'c': VizPackage('c', Version(2, 0, 0), {}, null, isPublishToNone: true),
    });

    final mermaid = root.toMermaid();
    check(mermaid).startsWith('flowchart TD');
    check(mermaid).contains('classDef primary');
    check(mermaid).contains('classDef outdated');
    check(mermaid).contains('classDef publishToNone');

    check(mermaid).contains('a["a<br/>1.0.0"]');
    check(mermaid).contains('b["b<br/>1.2.0<br/>(latest: 1.3.0)"]');
    check(mermaid).contains('c("c<br/>2.0.0")');

    check(mermaid).contains('a -- "^1.0.0"--> b');
    check(mermaid).contains('a -.-> c');

    check(mermaid).contains('class a primary;');
    check(mermaid).contains('class b outdated;');
    check(mermaid).contains('class c publishToNone;');
  });

  test('toMermaid styles outdated and dev-only edges with linkStyle', () {
    final root = VizRoot.assemble('a', {
      'a': VizPackage(
        'a',
        Version(1, 0, 0),
        {
          Dependency('b', VersionConstraint.parse('^1.0.0'), false),
          Dependency('c', VersionConstraint.parse('^1.0.0'), true),
        },
        null,
        isPrimary: true,
        onlyDev: false,
      ),
      'b': VizPackage(
        'b',
        Version(1, 0, 0),
        {},
        Version(2, 0, 0),
        onlyDev: false,
      ),
      'c': VizPackage('c', Version(1, 0, 0), {
        Dependency('b', VersionConstraint.parse('^1.0.0'), false),
        Dependency('d', VersionConstraint.parse('^1.0.0'), false),
      }, Version(1, 0, 0)),
      'd': VizPackage('d', Version(1, 0, 0), {}, Version(1, 0, 0)),
    }, flagOutdated: true);

    final mermaid = root.toMermaid();
    // Edge 0: a -> b (outdated prod edge: ^1.0.0 does not allow 2.0.0)
    // Edge 1: a -.-> c (non-outdated dev edge)
    // Edge 2: c -> b (outdated onlyDev edge: ^1.0.0 does not allow 2.0.0)
    // Edge 3: c -> d (non-outdated onlyDev edge: gray)
    check(mermaid).contains('linkStyle 3 stroke:#9e9e9e,color:#9e9e9e;');
    check(mermaid)
        .contains('linkStyle 0 stroke:#e53935,color:#e53935,stroke-width:2px;');
    check(mermaid)
        .contains('linkStyle 2 stroke:#f48fb1,color:#e53935,stroke-width:2px;');
  });
}
