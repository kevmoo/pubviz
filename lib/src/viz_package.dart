import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'converters.dart';
import 'dependency.dart';

part 'viz_package.g.dart';

@JsonSerializable(includeIfNull: false)
class VizPackage implements Comparable<VizPackage> {
  final String name;
  @VersionConverter()
  final Version? version;
  final Set<Dependency> dependencies;

  @FalseNullConverter()
  bool isPrimary;

  @FalseNullConverter()
  bool onlyDev = true;

  @VersionConverter()
  final Version? latestVersion;

  VizPackage(
    this.name,
    this.version,
    Set<Dependency> dependencies,
    this.latestVersion, {
    this.isPrimary = false,
    this.onlyDev = true,
  }) : dependencies = UnmodifiableSetView(dependencies);

  factory VizPackage.fromJson(Map<String, dynamic> json) =>
      _$VizPackageFromJson(json);

  Map<String, dynamic> toJson() => _$VizPackageToJson(this);

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
