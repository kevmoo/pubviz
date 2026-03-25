import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as parse;

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

  static Set<Dependency> getDependencies(
    parse.Pubspec pubspec, {
    bool includeDevDependencies = true,
  }) {
    final deps = <Dependency>{};

    _populateFromSection(pubspec.dependencies, deps, false);
    if (includeDevDependencies) {
      _populateFromSection(pubspec.devDependencies, deps, true);
    }
    return deps;
  }

  static void _populateFromSection(
    Map<String, parse.Dependency> yaml,
    Set<Dependency> value,
    bool isDev,
  ) {
    for (var entry in yaml.entries) {
      final constraint = entry.value;
      final constraintString = (constraint is parse.HostedDependency)
          ? constraint.version.toString()
          : constraint.toString();

      final dep = Dependency(entry.key, _parseOrNull(constraintString), isDev);

      value.add(dep);
    }
  }

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

VersionConstraint _parseOrNull(String input) {
  try {
    return VersionConstraint.parse(input);
  } on FormatException {
    return VersionConstraint.empty;
  }
}
