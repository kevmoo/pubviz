import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';

abstract class Service {
  Pubspec pubspecForDirectory(String directory) {
    assert(Directory(directory).existsSync(), '`$directory` does not exist.');

    final pubspecPath = p.join(directory, 'pubspec.yaml');

    return Pubspec.parse(
      File(pubspecPath).readAsStringSync(),
      sourceUrl: pubspecPath,
    );
  }

  Map<String, dynamic> listPackageDirs(String directory);

  Future<List<String>> queryVersions(String packageName);
}
