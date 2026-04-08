import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

/// Sets up a fake project to resolve dependencies for a published package.
Future<Directory> setupPublishedPackageProject(String targetPackage) async {
  final (name, version) = switch (targetPackage.split(':')) {
    [final n, final v] => (n, v),
    [final n] => (n, 'any'),
    _ => throw ArgumentError.value(
      targetPackage,
      'targetPackage',
      'Invalid package format',
    ),
  };

  final tempDir = Directory.systemTemp.createTempSync('pubviz_');
  try {
    File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: pubviz_fake
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  $name: $version
''');

    print('Resolving dependencies for $name...');
    final result = Process.runSync('dart', [
      'pub',
      'get',
    ], workingDirectory: tempDir.path);

    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      throw StateError('Failed to resolve dependencies for $name');
    }

    return tempDir;
  } catch (e) {
    tempDir.deleteSync(recursive: true);
    rethrow;
  }
}
