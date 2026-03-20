@Tags(['presubmit-only'])
library;

import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('ensure web assets are built and up-to-date', () {
    final jsAsset = File('lib/assets/web_app.dart.js');
    if (!jsAsset.existsSync()) {
      fail('Web assets not found. Run `dart tool/update_assets.dart`');
    }

    final jsModTime = jsAsset.lastModifiedSync();

    final inputDirsAndFiles = [Directory('_example_src'), File('pubspec.yaml')];

    print('Asset JS compiled at: $jsModTime');

    for (final source in inputDirsAndFiles) {
      if (!source.existsSync()) continue;

      final entities = source is Directory
          ? source.listSync(recursive: true).whereType<File>()
          : [source as File];

      for (var file in entities) {
        if (file.path.contains('.dart_tool') || file.path.contains('build/')) {
          continue;
        }

        // Skip hidden files to be safe
        if (file.uri.pathSegments.last.startsWith('.')) {
          continue;
        }

        final modTime = file.lastModifiedSync();

        if (modTime.isAfter(jsModTime)) {
          fail(
            'Source file ${file.path} (modified $modTime) is newer than '
            'generated output (modified $jsModTime).\n'
            'Please run `dart tool/update_assets.dart` and commit the updated '
            'files in `lib/assets/`',
          );
        }
      }
    }
  });
}
