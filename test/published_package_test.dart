@TestOn('vm')
library;

import 'package:checks/checks.dart';
import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/published_package.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('setupPublishedPackageProject validation', () {
    test(
      'throws UsageException for invalid format (too many colons)',
      () async {
        await check(setupPublishedPackageProject('a:b:c'))
            .throws<UsageException>(
              (it) => it
                  .has((e) => e.message, 'message')
                  .contains('Invalid package format'),
            );
      },
    );

    test(
      'throws UsageException for invalid package name (starts with number)',
      () async {
        await check(setupPublishedPackageProject('1a')).throws<UsageException>(
          (it) => it
              .has((e) => e.message, 'message')
              .contains('Invalid package name'),
        );
      },
    );

    test(
      'throws UsageException for invalid package name (contains hyphen)',
      () async {
        await check(setupPublishedPackageProject('a-b')).throws<UsageException>(
          (it) => it
              .has((e) => e.message, 'message')
              .contains('Invalid package name'),
        );
      },
    );

    test(
      'throws UsageException for invalid package name (uppercase)',
      () async {
        await check(setupPublishedPackageProject('A')).throws<UsageException>(
          (it) => it
              .has((e) => e.message, 'message')
              .contains('Invalid package name'),
        );
      },
    );

    test('throws UsageException for invalid version constraint', () async {
      await check(setupPublishedPackageProject('a:invalid-version'))
          .throws<UsageException>(
            (it) => it
                .has((e) => e.message, 'message')
                .contains('Invalid version constraint'),
          );
    });
  });
}
