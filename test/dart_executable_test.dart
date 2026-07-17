@TestOn('vm')
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/src/pub_data_service.dart';
import 'package:test/scaffolding.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('dartExecutable', () {
    test('handles non-file URI schemes without throwing UnsupportedError', () {
      final result = dartExecutable(
        script: Uri.parse('package:pubviz/pubviz.dart'),
        resolvedExecutable: '/custom/dart-sdk/bin/dart',
        version: '3.12.0 (stable)',
      );

      check(result).equals('/custom/dart-sdk/bin/dart');
    });

    test(
      'resolves Dart SDK from FLUTTER_ROOT when running as compiled executable',
      () async {
        final exeName = Platform.isWindows ? 'dart.exe' : 'dart';
        await d.dir('flutter_sdk', [
          d.dir('bin', [
            d.dir('cache', [
              d.dir('dart-sdk', [
                d.dir('bin', [d.file(exeName, 'binary content')]),
              ]),
            ]),
          ]),
        ]).create();

        final flutterRoot = p.join(d.sandbox, 'flutter_sdk');
        final expectedDart = p.join(
          flutterRoot,
          'bin',
          'cache',
          'dart-sdk',
          'bin',
          exeName,
        );

        final result = dartExecutable(
          script: Uri.file('/usr/local/bin/pubviz'),
          resolvedExecutable: '/usr/local/bin/pubviz',
          version: '3.12.0 (exe)',
          environment: {'FLUTTER_ROOT': flutterRoot},
        );

        check(result).equals(expectedDart);
      },
    );

    test(
      'resolves Dart SDK from DART_SDK when running as compiled executable',
      () async {
        final exeName = Platform.isWindows ? 'dart.exe' : 'dart';
        await d.dir('dart_sdk', [
          d.dir('bin', [d.file(exeName, 'binary content')]),
        ]).create();

        final sdkRoot = p.join(d.sandbox, 'dart_sdk');
        final expectedDart = p.join(sdkRoot, 'bin', exeName);

        final result = dartExecutable(
          script: Uri.file('/usr/local/bin/pubviz'),
          resolvedExecutable: '/usr/local/bin/pubviz',
          version: '3.12.0 (exe)',
          environment: {'DART_SDK': sdkRoot},
        );

        check(result).equals(expectedDart);
      },
    );

    test('defaults to bare executable name when running as compiled executable '
        'without SDK env vars', () {
      final exeName = Platform.isWindows ? 'dart.exe' : 'dart';
      final result = dartExecutable(
        script: Uri.file('/usr/local/bin/pubviz'),
        resolvedExecutable: '/usr/local/bin/pubviz',
        version: '3.12.0 (exe)',
        environment: {},
      );

      check(result).equals(exeName);
    });
  });
}
