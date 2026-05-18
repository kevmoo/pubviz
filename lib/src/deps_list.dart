import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

class DepsList {
  final Map<String, Version> sdks;
  final Map<String, DepsPackageEntry> packages;
  final String rootPackageName;
  final Map<VersionedEntry, Map<String, VersionConstraint>>
  transitiveDependencies;

  DepsPackageEntry get rootPackage => packages[rootPackageName]!;

  DepsList._(
    this.sdks,
    this.packages,
    this.rootPackageName, {
    required this.transitiveDependencies,
  }) {
    for (var entry in packages.values) {
      entry._parent = this;
    }
  }

  factory DepsList.fromJson(Map<String, dynamic> json) {
    final sdks = <String, Version>{
      for (final sdk in (json['sdks'] as List).cast<Map<String, dynamic>>())
        sdk['name'] as String: Version.parse(sdk['version'] as String),
    };

    final rootPackageName = json['root'] as String;

    final allPackagesJson = {
      for (final pkg in (json['packages'] as List).cast<Map<String, dynamic>>())
        pkg['name'] as String: pkg,
    };

    VersionedEntry makeVersionedEntry(String name) {
      final pkg = allPackagesJson[name];
      if (pkg == null) {
        throw StateError('Could not find package entry for `$name` in JSON.');
      }
      return VersionedEntry(name, Version.parse(pkg['version'] as String));
    }

    Map<String, VersionConstraint> getConstraints(Map<String, dynamic> pkg) {
      final constraints = pkg['dependencyConstraints'] as Map?;
      return {
        if (constraints != null)
          for (final entry in constraints.entries)
            entry.key as String: VersionConstraint.parse(entry.value as String),
      };
    }

    final pkgs = <String, DepsPackageEntry>{};
    final transitiveDeps = <VersionedEntry, Map<String, VersionConstraint>>{};

    for (final pkg in allPackagesJson.values) {
      final name = pkg['name'] as String;
      final kind = pkg['kind'] as String;

      if (kind == 'root') {
        final directDepsList =
            (pkg['directDependencies'] as List?)?.cast<String>() ?? const [];
        final devDepsList =
            (pkg['devDependencies'] as List?)?.cast<String>() ?? const [];

        final directDepsSet = directDepsList.toSet();
        final devDepsSet = devDepsList.toSet();

        final dependenciesSection =
            <VersionedEntry, Map<String, VersionConstraint>>{
              for (final depName in directDepsSet)
                makeVersionedEntry(depName): getConstraints(
                  allPackagesJson[depName]!,
                ),
            };

        final devDependenciesSection =
            <VersionedEntry, Map<String, VersionConstraint>>{
              for (final depName in devDepsSet)
                makeVersionedEntry(depName): getConstraints(
                  allPackagesJson[depName]!,
                ),
            };

        final sections =
            <String, Map<VersionedEntry, Map<String, VersionConstraint>>>{
              if (dependenciesSection.isNotEmpty)
                'dependencies': dependenciesSection,
              if (devDependenciesSection.isNotEmpty)
                'dev dependencies': devDependenciesSection,
            };

        final sourcePackage = makeVersionedEntry(name);
        pkgs[name] = DepsPackageEntry._(sourcePackage, sections);
      } else {
        transitiveDeps[makeVersionedEntry(name)] = getConstraints(pkg);
      }
    }

    return DepsList._(
      sdks,
      pkgs,
      rootPackageName,
      transitiveDependencies: transitiveDeps,
    );
  }

  Map<String, dynamic> toJson() => {
    'sdks': sdks,
    'packages': packages,
    'rootPackageName': rootPackageName,
    'transitiveDependencies': transitiveDependencies.map(
      (k, v) => MapEntry(k.toString(), v),
    ),
  };
}

class DepsPackageEntry extends VersionedEntry {
  final Map<String, Map<VersionedEntry, Map<String, VersionConstraint>>>
  sections;

  late final DepsList _parent;

  Map<VersionedEntry, Map<String, VersionConstraint>> get allEntries =>
      CombinedMapView([
        _parent.transitiveDependencies,
        ..._parent.packages.values.expand((e) => e.sections.values),
      ]);

  DepsPackageEntry._(super.entry, this.sections) : super.copy();

  Map<String, dynamic> toJson() => {
    'name': name,
    'version': version.toString(),
    'sections': {
      for (var section in sections.entries)
        section.key: {
          for (var usage in section.value.entries)
            usage.key.toString(): {
              for (var dep in usage.value.entries)
                dep.key: dep.value.toString(),
            },
        },
    },
  };
}

class VersionedEntry {
  final String name;
  final Version version;

  VersionedEntry(this.name, this.version);

  VersionedEntry.copy(VersionedEntry other)
    : name = other.name,
      version = other.version;

  @override
  String toString() => '$name @ $version';

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is VersionedEntry && name == other.name;
}
