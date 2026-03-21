@Tags(['presubmit'])
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('ensure web assets are built and up-to-date', () {
    final inputDirsAndFiles = [Directory('_example_src'), File('pubspec.yaml')];

    // 1. Verify static non-compiled files exactly match
    final staticAssets = ['index.html', 'style.css', 'favicon.ico'];
    for (final filename in staticAssets) {
      final sourceFile = File(p.join('_example_src', filename));
      final assetFile = File(p.join('lib', 'assets', filename));

      if (sourceFile.existsSync() && assetFile.existsSync()) {
        final sourceBytes = sourceFile.readAsBytesSync();
        final assetBytes = assetFile.readAsBytesSync();
        if (sourceBytes.length != assetBytes.length ||
            !_listsEqual(sourceBytes, assetBytes)) {
          fail(
            '`lib/assets/$filename` does not match `_example_src/$filename`.\n'
            'Please run `dart tool/update_assets.dart` and commit the updated files.',
          );
        }
      } else if (sourceFile.existsSync() && !assetFile.existsSync()) {
        fail(
          '`lib/assets/$filename` is missing. Please run `dart tool/update_assets.dart`.',
        );
      }
    }

    // 2. Fetch the max commit time of all input files
    var maxInputTime = DateTime.fromMillisecondsSinceEpoch(0);
    for (final source in inputDirsAndFiles) {
      if (!source.existsSync()) continue;

      final entities = source is Directory
          ? source.listSync(recursive: true).whereType<File>()
          : [source as File];

      for (var file in entities) {
        if (file.path.contains('.dart_tool') || file.path.contains('build/')) {
          continue;
        }

        // skip hidden and static assets (we checked static assets via diff!)
        final basename = p.basename(file.path);
        if (basename.startsWith('.') || staticAssets.contains(basename)) {
          continue;
        }

        final modTime = _gitCommitTime(file.path);
        if (modTime.isAfter(maxInputTime)) {
          maxInputTime = modTime;
        }
      }
    }

    // 3. Ensure the build_version was updated and committed
    // This file is always modified by `update_assets.dart` so it's guaranteed
    // to force a Git commit even if the JS/Wasm output is identical byte-for-byte.
    final buildVersionFile = File(p.join('lib', 'assets', 'build_version.txt'));
    if (!buildVersionFile.existsSync()) {
      fail(
        'Compiled asset tracking file not found. Run `dart tool/update_assets.dart`',
      );
    }

    final modTime = _gitCommitTime(buildVersionFile.path);
    if (maxInputTime.isAfter(modTime)) {
      fail(
        'Input files (committed $maxInputTime) are newer than '
        'the last assets build (committed $modTime).\n'
        'Please run `dart tool/update_assets.dart` and commit the updated files.',
      );
    }
  });
}

bool _listsEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

DateTime _gitCommitTime(String path) {
  _ensureNotDirty(path);

  final result = Process.runSync('git', [
    'log',
    '-1',
    '--format=%cI',
    '--',
    path,
  ]);
  if (result.exitCode != 0) {
    fail('git log failed for $path');
  }
  final output = (result.stdout as String).trim();
  if (output.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.parse(output);
}

void _ensureNotDirty(String path) {
  final result = Process.runSync('git', ['status', '--porcelain', '--', path]);
  if (result.exitCode != 0) {
    fail('git status failed for $path');
  }
  if ((result.stdout as String).trim().isNotEmpty) {
    fail(
      'Cannot validate files because there are local uncommitted changes.\n'
      'File: $path is dirty.\n'
      'Please commit or stash your changes before running this test.',
    );
  }
}
