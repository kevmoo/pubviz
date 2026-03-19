import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';

class VizPackage implements Comparable<VizPackage> {
  final String name;
  final Version? version;
  final Set<Dependency> dependencies;
  bool isPrimary;

  bool _onlyDev = true;

  bool get onlyDev => _onlyDev;

  set onlyDev(bool value) {
    _onlyDev = value;
  }

  final Version? latestVersion;

  VizPackage(
    this.name,
    this.version,
    Set<Dependency> deps,
    this.latestVersion, {
    this.isPrimary = false,
  }) : dependencies = UnmodifiableSetView(deps);

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
}
