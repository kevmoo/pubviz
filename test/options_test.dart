import 'package:checks/checks.dart';
import 'package:pubviz/src/options.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('parseOptions', () {
    test('defaults', () {
      final options = parseOptions([]);
      check(options.action).equals(Action.open);
      check(options.flagOutdated).equals(true);
      check(options.ignorePackages).isEmpty();
      check(options.productionDependencies).equals(false);
      check(options.version).equals(false);
      check(options.help).equals(false);
    });

    test('all flags', () {
      final options = parseOptions([
        '--action',
        'print',
        '--ignore-packages',
        'a,b',
        '--no-flag-outdated',
        '--direct-dependencies',
        '--production-dependencies',
        '--version',
        '--help',
        '--workspace',
        '--filters',
        'hide-dev',
        '--package',
        'pubviz:1.0.0',
      ]);
      check(options.action).equals(Action.print);
      check(options.ignorePackages).deepEquals(['a', 'b']);
      check(options.flagOutdated).equals(false);
      check(options.directDependencies).equals(true);
      check(options.productionDependencies).equals(true);
      check(options.version).equals(true);
      check(options.help).equals(true);
      check(options.workspace).equals(true);
      check(options.filters).deepEquals(['hide-dev']);
      check(options.package).equals('pubviz:1.0.0');
    });

    test('rest arguments', () {
      final options = parseOptions(['path/to/pkg']);
      check(options.rest).deepEquals(['path/to/pkg']);
    });
  });

  test('UsageException toString', () {
    check(UsageException('bob').toString()).equals('bob');
  });
}
