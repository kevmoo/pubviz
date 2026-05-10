import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/dependency.dart';
import 'package:pubviz/src/mermaid.dart';
import 'package:pubviz/src/viz_package.dart';
import 'package:pubviz/src/viz_root.dart';
import 'package:test/test.dart';

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
    expect(mermaid, startsWith('flowchart TD'));
    expect(mermaid, contains('classDef primary'));
    expect(mermaid, contains('classDef outdated'));
    expect(mermaid, contains('classDef publishToNone'));

    expect(mermaid, contains('a["a<br/>1.0.0"]'));
    expect(mermaid, contains('b["b<br/>1.2.0<br/>(latest: 1.3.0)"]'));
    expect(mermaid, contains('c("c<br/>2.0.0")'));

    expect(mermaid, contains('a -- "^1.0.0"--> b'));
    expect(mermaid, contains('a -.-> c'));

    expect(mermaid, contains('class a primary;'));
    expect(mermaid, contains('class b outdated;'));
    expect(mermaid, contains('class c publishToNone;'));
  });
}
