@Tags(['presubmit'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../tool/shared.dart';

const _staticAssets = {'index.html', 'style.css', 'favicon.ico'};

void main() {
  test('ensure web assets are built and up-to-date', () async {
    // 1. Verify static non-compiled files exactly match
    for (final filename in _staticAssets) {
      final sourceFile = File(p.join('web', filename));
      final assetFile = File(p.join('lib', 'assets', filename));

      if (sourceFile.existsSync() && assetFile.existsSync()) {
        final sourceBytes = sourceFile.readAsBytesSync();
        final assetBytes = assetFile.readAsBytesSync();
        if (!(const ListEquality<int>().equals(sourceBytes, assetBytes))) {
          fail(
            '`lib/assets/$filename` does not match `web/$filename`.\n'
            'Please run `dart tool/update_assets.dart` and commit the updated files.',
          );
        }
      } else if (sourceFile.existsSync() && !assetFile.existsSync()) {
        fail(
          '`lib/assets/$filename` is missing. Please run `dart tool/update_assets.dart`.',
        );
      }
    }

    // 2. Ensure the build_version hash matches current inputs
    final buildVersionFile = File(p.join('lib', 'assets', assetFileName));
    if (!buildVersionFile.existsSync()) {
      fail(
        'Compiled asset tracking file not found. Run `dart tool/update_assets.dart`',
      );
    }

    final expectedJson = await hashInputs();
    final actualJson = buildVersionFile.readAsStringSync().trim();
    if (expectedJson != actualJson) {
      final errorMessage = StringBuffer(
        'Input files have changed since the last assets build.',
      );
      final expectedMap = jsonDecode(expectedJson) as Map<String, dynamic>;
      final actualMap = jsonDecode(actualJson) as Map<String, dynamic>;

      final allKeys = {...expectedMap.keys, ...actualMap.keys};
      final changedFiles = allKeys
          .where((key) => expectedMap[key] != actualMap[key])
          .toSet();
      if (changedFiles.isNotEmpty) {
        errorMessage.writeln(
          'Files changed:\n'
          '${changedFiles.map((f) => '  - $f').join('\n')}\n',
        );
      }
      fail(
        '$errorMessage'
        'Please run `dart tool/update_assets.dart` and commit the updated files.',
      );
    }
  });
}
