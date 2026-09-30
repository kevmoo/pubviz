import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'converters.dart';

part 'dependency.g.dart';

@JsonSerializable(includeIfNull: false)
class Dependency implements Comparable<Dependency> {
  final String name;
  @VersionConstraintConverter()
  final VersionConstraint versionConstraint;

  @FalseNullConverter()
  final bool isDevDependency;

  final bool? includesLatest;

  Dependency(
    this.name,
    this.versionConstraint,
    this.isDevDependency, {
    this.includesLatest,
  });

  factory Dependency.fromJson(Map<String, dynamic> json) =>
      _$DependencyFromJson(json);

  Map<String, dynamic> toJson() => _$DependencyToJson(this);

  @override
  bool operator ==(Object other) => other is Dependency && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  int compareTo(Dependency other) {
    if (other.isDevDependency == isDevDependency) {
      return name.compareTo(other.name);
    } else if (isDevDependency) {
      return 1;
    } else {
      return -1;
    }
  }

  @override
  String toString() {
    final devStr = isDevDependency ? '(dev)' : '';
    return '$name$devStr $versionConstraint';
  }
}
