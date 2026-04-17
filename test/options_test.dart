import 'package:pubviz/src/options.dart';
import 'package:test/test.dart';

void main() {
  group('parseOptions', () {
    test('defaults', () {
      final options = parseOptions([]);
      expect(options.action, Action.open);
      expect(options.flagOutdated, isTrue);
      expect(options.ignorePackages, isEmpty);
      expect(options.productionDependencies, isFalse);
      expect(options.version, isFalse);
      expect(options.help, isFalse);
    });

    test('all flags', () {
      final options = parseOptions([
        '--action', 'print',
        '--ignore-packages', 'a,b',
        '--no-flag-outdated',
        '--direct-dependencies',
        '--production-dependencies',
        '--version',
        '--help',
        '--workspace',
        '--filters', 'hide-dev',
        '--package', 'pubviz:1.0.0',
      ]);
      expect(options.action, Action.print);
      expect(options.ignorePackages, ['a', 'b']);
      expect(options.flagOutdated, isFalse);
      expect(options.directDependencies, isTrue);
      expect(options.productionDependencies, isTrue);
      expect(options.version, isTrue);
      expect(options.help, isTrue);
      expect(options.workspace, isTrue);
      expect(options.filters, ['hide-dev']);
      expect(options.package, 'pubviz:1.0.0');
    });

    test('rest arguments', () {
      final options = parseOptions(['path/to/pkg']);
      expect(options.rest, ['path/to/pkg']);
    });
  });

  test('UsageException toString', () {
    expect(UsageException('bob').toString(), 'bob');
  });
}
