import 'package:checks/checks.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/dependency.dart';
import 'package:pubviz/src/dot.dart';
import 'package:pubviz/src/viz_package.dart';
import 'package:pubviz/src/viz_root.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('toDot with root dependency', () {
    final root = VizRoot('a', {
      'a': VizPackage(
        'a',
        Version(1, 0, 0),
        {Dependency('b', VersionConstraint.any, false)},
        null,
        isPrimary: true,
      ),
      'b': VizPackage('b', Version(1, 0, 0), {
        Dependency('a', VersionConstraint.any, false),
      }, null),
    });

    final dot = root.toDot();
    check(dot).contains('b -> a [color=gray, constraint=false];');
  });
}
