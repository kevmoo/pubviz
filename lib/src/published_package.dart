import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'options.dart';

/// Sets up a fake project to resolve dependencies for a published package.
Future<({Directory directory, String packageName})>
setupPublishedPackageProject(String targetPackage) async {
  final (name, version) = switch (targetPackage.split(':')) {
    [final n, final v] => (n, v),
    [final n] => (n, 'any'),
    _ => throw UsageException('Invalid package format: $targetPackage'),
  };

  if (!RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name)) {
    throw UsageException('Invalid package name: $name');
  }

  try {
    VersionConstraint.parse(version);
  } on FormatException catch (e) {
    throw UsageException('Invalid version constraint "$version": ${e.message}');
  }

  final tempDir = Directory.systemTemp.createTempSync('pubviz_');
  try {
    File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: pubviz_fake
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  $name: $version
''');

    stderr.writeln('Resolving dependencies for $name...');
    final result = Process.runSync('dart', [
      'pub',
      'get',
    ], workingDirectory: tempDir.path);

    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      throw StateError('Failed to resolve dependencies for $name');
    }

    return (directory: tempDir, packageName: name);
  } catch (e) {
    tempDir.deleteSync(recursive: true);
    rethrow;
  }
}
