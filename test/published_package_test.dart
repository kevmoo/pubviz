@TestOn('vm')
library;

import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/published_package.dart';
import 'package:test/test.dart';

void main() {
  group('setupPublishedPackageProject validation', () {
    test('throws UsageException for invalid format (too many colons)', () {
      expect(
        setupPublishedPackageProject('a:b:c'),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains('Invalid package format'),
          ),
        ),
      );
    });

    test(
      'throws UsageException for invalid package name (starts with number)',
      () {
        expect(
          setupPublishedPackageProject('1a'),
          throwsA(
            isA<UsageException>().having(
              (e) => e.message,
              'message',
              contains('Invalid package name'),
            ),
          ),
        );
      },
    );

    test(
      'throws UsageException for invalid package name (contains hyphen)',
      () {
        expect(
          setupPublishedPackageProject('a-b'),
          throwsA(
            isA<UsageException>().having(
              (e) => e.message,
              'message',
              contains('Invalid package name'),
            ),
          ),
        );
      },
    );

    test('throws UsageException for invalid package name (uppercase)', () {
      expect(
        setupPublishedPackageProject('A'),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains('Invalid package name'),
          ),
        ),
      );
    });

    test('throws UsageException for invalid version constraint', () {
      expect(
        setupPublishedPackageProject('a:invalid-version'),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains('Invalid version constraint'),
          ),
        ),
      );
    });
  });
}
