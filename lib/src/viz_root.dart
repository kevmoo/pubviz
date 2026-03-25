import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';
import 'viz_package.dart';

part 'viz_root.g.dart';

@JsonSerializable()
class VizRoot {
  final String rootPackageName;
  final Map<String, VizPackage> packages;

  VizRoot(this.rootPackageName, Map<String, VizPackage> packages)
    : assert(packages.containsKey(rootPackageName)),
      packages = UnmodifiableMapView(packages);

  factory VizRoot.fromJson(Map<String, dynamic> json) =>
      _$VizRootFromJson(json);

  Map<String, dynamic> toJson() => _$VizRootToJson(this);

  VizPackage get root => packages[rootPackageName]!;

  static VizRoot assemble(
    String rootPackageName,
    Map<String, VizPackage> packages, {
    bool flagOutdated = false,
    Iterable<String>? ignorePackages,
  }) {
    var primaryPackageNames = packages.values
        .where((p) => p.isPrimary)
        .map((p) => p.name)
        .toSet();
    if (primaryPackageNames.isEmpty) {
      primaryPackageNames = {rootPackageName};
    }

    final nonDevReachable = <String>{};
    final queue = [...primaryPackageNames];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (nonDevReachable.add(current)) {
        final pkg = packages[current];
        if (pkg != null) {
          for (var dep in pkg.dependencies) {
            if (!dep.isDevDependency) {
              queue.add(dep.name);
            }
          }
        }
      }
    }

    final newPackages = <String, VizPackage>{};
    final ignoreSet = ignorePackages?.toSet() ?? {};

    for (var entry in packages.entries) {
      final name = entry.key;
      final pkg = entry.value;
      final skipOutdated = ignoreSet.contains(name);

      final newDeps = pkg.dependencies.map((dep) {
        bool? includesLatest;
        if (flagOutdated && !skipOutdated) {
          final depPackage = packages[dep.name];
          if (depPackage != null &&
              depPackage.latestVersion != null &&
              dep.versionConstraint != VersionConstraint.empty) {
            var allowsLatest = dep.versionConstraint.allows(
              depPackage.latestVersion!,
            );

            if (!allowsLatest) {
              final constraint = dep.versionConstraint;
              if (constraint is VersionRange) {
                final min = constraint.min;
                if (min != null &&
                    min.isPreRelease &&
                    min.compareTo(depPackage.latestVersion!) > 0) {
                  allowsLatest = true;
                }
              }
            }
            includesLatest = allowsLatest;
          }
        }
        return Dependency(
          dep.name,
          dep.versionConstraint,
          dep.isDevDependency,
          includesLatest: includesLatest,
        );
      }).toSet();

      newPackages[name] = VizPackage(
        pkg.name,
        pkg.version,
        newDeps,
        pkg.latestVersion,
        isPrimary: primaryPackageNames.contains(name),
        onlyDev: !nonDevReachable.contains(name),
      );
    }

    return VizRoot(rootPackageName, newPackages);
  }

  VizRoot filter({required bool excludeDev, required bool onlyOutdated}) {
    if (!excludeDev && !onlyOutdated) return this;

    final newPackages = onlyOutdated
        ? _filterOutdated(excludeDev)
        : _filterStandard(excludeDev);

    return VizRoot.assemble(rootPackageName, newPackages);
  }

  Map<String, VizPackage> _filterOutdated(bool excludeDev) {
    final newPackages = <String, VizPackage>{};
    final primaryPackages = packages.values
        .where((p) => p.isPrimary)
        .map((p) => p.name)
        .toList();
    final reachableFromRoot = <String>{...primaryPackages, rootPackageName};
    final rootQueue = <String>[...reachableFromRoot];
    while (rootQueue.isNotEmpty) {
      final current = rootQueue.removeLast();
      final orig = packages[current];
      if (orig != null) {
        for (var dep in orig.dependencies) {
          if (excludeDev && dep.isDevDependency) continue;
          if (reachableFromRoot.add(dep.name)) {
            rootQueue.add(dep.name);
          }
        }
      }
    }

    final incoming = <String, Set<String>>{};
    for (var pkgName in reachableFromRoot) {
      final pkg = packages[pkgName];
      if (pkg != null) {
        for (var dep in pkg.dependencies) {
          if (excludeDev && dep.isDevDependency) continue;
          incoming.putIfAbsent(dep.name, () => {}).add(pkg.name);
        }
      }
    }

    final outdatedNodes = reachableFromRoot.where((name) {
      final p = packages[name];
      return p != null &&
          p.latestVersion != null &&
          p.latestVersion!.compareTo(p.version!) > 0;
    }).toSet();

    final queue = outdatedNodes.toList();
    final keepNodes = Set<String>.from(outdatedNodes);

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      for (var parent in incoming[current] ?? <String>{}) {
        if (keepNodes.add(parent)) {
          queue.add(parent);
        }
      }
    }

    keepNodes.add(rootPackageName);

    for (var pkgName in keepNodes) {
      final orig = packages[pkgName];
      if (orig != null) {
        final filteredDeps = orig.dependencies
            .where(
              (d) =>
                  keepNodes.contains(d.name) &&
                  (!excludeDev || !d.isDevDependency),
            )
            .toSet();

        newPackages[pkgName] = VizPackage(
          orig.name,
          orig.version,
          filteredDeps,
          orig.latestVersion,
          isPrimary: orig.isPrimary,
        );
      }
    }
    return newPackages;
  }

  Map<String, VizPackage> _filterStandard(bool excludeDev) {
    final newPackages = <String, VizPackage>{};
    final primaryPackages = packages.values
        .where((p) => p.isPrimary)
        .map((p) => p.name)
        .toList();
    final keepNodes = <String>{...primaryPackages, rootPackageName};
    final queue = <String>[...keepNodes];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final orig = packages[current];
      if (orig == null) continue;

      for (var dep in orig.dependencies) {
        if (excludeDev && dep.isDevDependency) continue;

        if (keepNodes.add(dep.name)) {
          queue.add(dep.name);
        }
      }
    }

    for (var pkgName in keepNodes) {
      final orig = packages[pkgName]!;
      newPackages[pkgName] = VizPackage(
        orig.name,
        orig.version,
        orig.dependencies
            .where((d) => !excludeDev || !d.isDevDependency)
            .toSet(),
        orig.latestVersion,
        isPrimary: orig.isPrimary,
      );
    }
    return newPackages;
  }
}
