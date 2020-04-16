import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

abstract class Service {
  Map<String, dynamic> _outdatedCache;

  String get rootPackageDir;

  Pubspec pubspecForDirectory(String directory) {
    assert(Directory(directory).existsSync(), '`$directory` does not exist.');

    final pubspecPath = p.join(directory, 'pubspec.yaml');

    return Pubspec.parse(
      File(pubspecPath).readAsStringSync(),
      sourceUrl: pubspecPath,
    );
  }

  Map<String, dynamic> listPackageDirs(String directory);

  Version latest(String package) {
    final list = (_outdatedCache ??= outdated())['packages'] as List;
    final map = list.cast<Map<String, dynamic>>().singleWhere(
        (element) => element['package'] == package,
        orElse: () => null);

    if (map == null) {
      return null;
    }

    final info = OutdatedInfo.fromJson(map);
    return info.latest;
  }

  Map<String, dynamic> outdated();
}

class OutdatedInfo {
  final String package;
  final Version current, upgradable, resolvable, latest;

  OutdatedInfo(
    this.package,
    this.current,
    this.upgradable,
    this.resolvable,
    this.latest,
  );

  factory OutdatedInfo.fromJson(Map<String, dynamic> json) => OutdatedInfo(
        json['package'] as String,
        _version(json, 'current'),
        _version(json, 'upgradable'),
        _version(json, 'resolvable'),
        _version(json, 'latest'),
      );
}

Version _version(Map<String, dynamic> json, String key) => Version.parse(
      (json[key] as Map<String, dynamic>)['version'] as String,
    );
