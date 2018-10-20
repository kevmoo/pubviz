import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' hide Dependency;

import 'dependency.dart';
import 'util.dart';

class VizPackage extends Comparable<VizPackage> {
  final String name;
  final Version version;
  final Set<Dependency> dependencies;
  final VersionConstraint sdkConstraint;
  bool isPrimary = false;

  bool _onlyDev = true;

  bool get onlyDev => _onlyDev;

  set onlyDev(bool value) {
    assert(value == false);
    assert(_onlyDev == true);

    _onlyDev = value;
  }

  Version _latestVersion;

  Version get latestVersion => _latestVersion;

  VizPackage._(
      this.name, this.version, Set<Dependency> deps, this.sdkConstraint)
      : dependencies = new UnmodifiableSetView(deps);

  static Future<VizPackage> forDirectory(String path,
      {bool flagOutdated = false}) async {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = p.join(path, 'pubspec.yaml');

    var pubspec = new Pubspec.parse(new File(pubspecPath).readAsStringSync(),
        sourceUrl: pubspecPath);
    var deps = Dependency.getDependencies(pubspec);
    var sdkConstraint = pubspec.environment['sdk'];

    var package =
        new VizPackage._(pubspec.name, pubspec.version, deps, sdkConstraint);

    if (flagOutdated) {
      await package._updateLatestVersion();
    }

    return package;
  }

  @override
  String toString() => '$name @ $version';

  @override
  int compareTo(VizPackage other) {
    return name.compareTo(other.name);
  }

  @override
  bool operator ==(Object other) {
    if (other is VizPackage) {
      var match = (name == other.name);
      if (match) {
        assert(other.version == version);
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  Future<Version> _updateLatestVersion() async {
    if (_latestVersion != null) return _latestVersion;
    if (version == null) {
      // Likely not published. Don't try.
      return null;
    }

    _latestVersion = await getLatestVersion(name, version.isPreRelease);

    if (_latestVersion != null) {
      assert(_latestVersion.compareTo(version) >= 0);
    }

    return _latestVersion;
  }
}
