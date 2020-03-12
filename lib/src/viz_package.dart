import 'dart:async';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';
import 'service.dart';
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

  final Version latestVersion;

  VizPackage._(
    this.name,
    this.version,
    Set<Dependency> deps,
    this.sdkConstraint,
    this.latestVersion,
  ) : dependencies = UnmodifiableSetView(deps);

  static Future<VizPackage> forDirectory(
    Service service,
    String path, {
    bool flagOutdated = false,
  }) async {
    final pubspec = service.pubspecForDirectory(path);
    final deps = Dependency.getDependencies(pubspec);
    final sdkConstraint = pubspec.environment['sdk'];

    Version latestVersion;

    if (flagOutdated) {
      latestVersion =
          await _latestVersion(service, pubspec.name, pubspec.version);
    }

    final package = VizPackage._(
      pubspec.name,
      pubspec.version,
      deps,
      sdkConstraint,
      latestVersion,
    );

    return package;
  }

  @override
  String toString() => '$name @ $version';

  @override
  int compareTo(VizPackage other) => name.compareTo(other.name);

  @override
  bool operator ==(Object other) {
    if (other is VizPackage) {
      final match = name == other.name;
      if (match) {
        assert(other.version == version);
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  static Future<Version> _latestVersion(
    Service service,
    String name,
    Version definedVersion,
  ) async {
    if (definedVersion == null) {
      // Likely not published. Don't try.
      return null;
    }

    final versions = await service.queryVersions(name);

    Version _latestVersion;
    if (versions != null) {
      _latestVersion = primaryVersion(
          versions.map((e) => Version.parse(e)).toList(),
          definedVersion.isPreRelease);
    }

    if (_latestVersion != null) {
      assert(_latestVersion.compareTo(definedVersion) >= 0);
    }

    return _latestVersion;
  }
}
