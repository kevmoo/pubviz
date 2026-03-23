import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';

part 'viz_package.g.dart';

@JsonSerializable()
class VizPackage implements Comparable<VizPackage> {
  final String name;
  @JsonKey(fromJson: _versionFromJson, toJson: _versionToJson)
  final Version? version;
  final Set<Dependency> dependencies;
  bool isPrimary;

  @JsonKey(defaultValue: true)
  bool onlyDev = true;

  @JsonKey(fromJson: _versionFromJson, toJson: _versionToJson)
  final Version? latestVersion;

  VizPackage(
    this.name,
    this.version,
    Set<Dependency> dependencies,
    this.latestVersion, {
    this.isPrimary = false,
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

Version? _versionFromJson(String? json) =>
    json == null ? null : Version.parse(json);

String? _versionToJson(Version? version) => version?.toString();
