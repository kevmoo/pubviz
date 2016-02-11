library pubviz.viz_package;

import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'dependency.dart';
import 'util.dart';

class VizPackage extends Comparable {
  final String name;
  final Version version;
  final Set<Dependency> dependencies;
  bool isPrimary = false;

  bool _onlyDev = true;

  bool get onlyDev => _onlyDev;

  void set onlyDev(bool value) {
    assert(value == false);
    assert(_onlyDev == true);

    _onlyDev = value;
  }

  Version _latestVersion;

  Version get latestVersion => _latestVersion;

  VizPackage._(this.name, this.version, Set<Dependency> deps)
      : dependencies = new UnmodifiableSetView(deps);

  static Future<VizPackage> forDirectory(String path,
      {bool flagOutdated: false}) async {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = p.join(path, 'pubspec.yaml');

    Map<String, dynamic> pubspecMap = await _openYaml(pubspecPath);

    String packageName = pubspecMap['name'];
    assert(packageName != null && packageName.length > 0);

    var versionString = pubspecMap['version'];
    var version =
        (versionString == null) ? null : new Version.parse(versionString);

    var deps = Dependency.getDependencies(pubspecMap);

    var package = new VizPackage._(packageName, version, deps);

    if (flagOutdated) {
      await package.updateLatestVersion();
    }

    return package;
  }

  String toString() => '$name @ $version';

  int compareTo(VizPackage other) {
    return name.compareTo(other.name);
  }

  bool operator ==(other) {
    if (other is VizPackage) {
      var match = (name == other.name);
      if (match) {
        assert(other.version == version);
        return true;
      }
    }
    return false;
  }

  int get hashCode => name.hashCode;

  Future<Version> updateLatestVersion() async {
    if (_latestVersion != null) return _latestVersion;

    _latestVersion = await getLatestVersion(name);

    return _latestVersion;
  }
}

Future<Map<String, dynamic>> _openYaml(String path) async {
  var file = new File(path);
  var value = await file.readAsString();
  return yaml.loadYaml(value);
}
