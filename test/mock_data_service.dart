import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pubviz/src/service.dart';

const populateFiles = false;

class MockDataService extends Service {
  @override
  final String rootPackageDir;

  MockDataService(this.rootPackageDir);

  @override
  Pubspec pubspecForDirectory(String directory) {
    if (populateFiles && !_validDir(directory)) {
      final existingPubspec = super.pubspecForDirectory(directory);
      final existingFileContent =
          File(p.join(directory, 'pubspec.yaml')).readAsStringSync();

      directory = p.join(rootPackageDir, existingPubspec.name);

      final newFilePath = p.join(directory, 'pubspec.yaml');
      stderr.writeln(newFilePath);
      File(newFilePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(existingFileContent);
    }

    assert(
      _validDir(directory),
      '`$directory` must be equal to or within `$rootPackageDir`',
    );
    return super.pubspecForDirectory(directory);
  }

  @override
  Map<String, dynamic> outdated() {
    final file = File(p.join(rootPackageDir, 'outdated.json'));
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> listPackageDirs(String directory) {
    assert(
      _validDir(directory),
      '`$directory` must be equal to or within `$rootPackageDir`',
    );

    final filePath = p.join(directory, 'list_package_dir.json');
    final file = File(filePath);
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  bool _validDir(String directory) =>
      p.equals(directory, rootPackageDir) ||
      p.isWithin(rootPackageDir, directory);
}
