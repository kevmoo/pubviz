import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/service.dart';

const populateFiles = false;

class MockDataService extends Service {
  final String _mockRoot;

  MockDataService(this._mockRoot);

  @override
  Pubspec pubspecForDirectory(String directory) {
    if (populateFiles && !_validDir(directory)) {
      final existingPubspec = super.pubspecForDirectory(directory);
      final existingFileContent =
          File(p.join(directory, 'pubspec.yaml')).readAsStringSync();

      directory = p.join(_mockRoot, existingPubspec.name);

      final newFilePath = p.join(directory, 'pubspec.yaml');
      stderr.writeln(newFilePath);
      File(newFilePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(existingFileContent);
    }

    assert(
      _validDir(directory),
      '`$directory` must be equal to or within `$_mockRoot`',
    );
    return super.pubspecForDirectory(directory);
  }

  @override
  Future<List<String>> queryVersions(String packageName) async {
    final mockPath = p.join(_mockRoot, packageName, 'versions.json');
    final mockFile = File(mockPath);
    if (populateFiles) {
      final service = PubDataService();
      try {
        final versions = await service.queryVersions(packageName);
        mockFile
          ..createSync(recursive: true)
          ..writeAsStringSync(
            const JsonEncoder.withIndent(' ').convert(versions),
          );
      } finally {
        service.close();
      }
    }
    return (jsonDecode(mockFile.readAsStringSync()) as List).cast<String>();
  }

  @override
  Map<String, dynamic> listPackageDirs(String directory) {
    assert(
      _validDir(directory),
      '`$directory` must be equal to or within `$_mockRoot`',
    );

    final filePath = p.join(directory, 'list_package_dir.json');
    final file = File(filePath);
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  bool _validDir(String directory) =>
      p.equals(directory, _mockRoot) || p.isWithin(_mockRoot, directory);
}
