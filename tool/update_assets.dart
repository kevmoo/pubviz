import 'dart:io';

import 'package:path/path.dart' as p;

import 'shared.dart';

void main() async {
  print('Building web assets via build_runner...');

  final tempDir = Directory('build/assets_temp');
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }

  final buildResult = await Process.start(Platform.executable, [
    'run',
    'build_runner',
    'build',
    '--release',
    '-o',
    'web:build/assets_temp',
  ], mode: ProcessStartMode.inheritStdio);

  if (await buildResult.exitCode != 0) {
    stderr.writeln('Build failed.');
    exitCode = 1;
    return;
  }

  if (!tempDir.existsSync()) {
    stderr.writeln('Error: build/assets_temp directory not found after build.');
    exitCode = 1;
    return;
  }

  final hash = await hashInputs();
  File(
    p.join('lib', 'src', 'assets.g.dart'),
  ).writeAsStringSync(generateEmbeddedAssetsString(tempDir, inputHashes: hash));

  tempDir.deleteSync(recursive: true);

  print('Successfully updated lib/src/assets.g.dart!');
}
