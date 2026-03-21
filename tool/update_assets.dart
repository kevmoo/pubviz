import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  print('Building web assets via build_runner...');

  final buildResult = await Process.start('dart', [
    'run',
    'build_runner',
    'build',
    '--release',
    '-o',
    '_example_src:build/assets_temp',
  ], mode: ProcessStartMode.inheritStdio);

  if (await buildResult.exitCode != 0) {
    stderr.writeln('Build failed:');
    exitCode = 1;
    return;
  }

  print('Copying built assets to lib/assets/...');
  final assetsDir = Directory('lib/assets');
  if (assetsDir.existsSync()) {
    assetsDir.deleteSync(recursive: true);
  }
  assetsDir.createSync(recursive: true);

  final tempDir = Directory('build/assets_temp');
  if (!tempDir.existsSync()) {
    stderr.writeln('Error: build/assets_temp directory not found after build.');
    exitCode = 1;
    return;
  }

  void copyDirectory(
    Directory source,
    Directory destination, {
    bool isRoot = false,
  }) {
    for (var entity in source.listSync()) {
      if (p.basename(entity.path).startsWith('.')) continue;
      if (isRoot &&
          entity is Directory &&
          p.basename(entity.path) == 'packages') {
        continue;
      }
      if (_ignoredFiles.contains(p.basename(entity.path))) continue;
      if (entity is Directory) {
        final newDirectory = Directory(
          p.join(destination.absolute.path, p.basename(entity.path)),
        )..createSync();
        copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        entity.copySync(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }

  copyDirectory(tempDir, assetsDir, isRoot: true);

  File(
    p.join(assetsDir.path, 'build_version.txt'),
  ).writeAsStringSync('${DateTime.now().toUtc().toIso8601String()}\n');

  print('Successfully updated lib/assets/!');
}

const _ignoredFiles = {
  'web_app.dart2js.js.deps',
  'web_app.dart2js.js.info.json',
};
