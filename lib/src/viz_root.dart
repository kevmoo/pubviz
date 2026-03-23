import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

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

  void update(bool includeWorkspace) {
    // Collect primary packages at the start.
    // If none are set (normal case), mark root as primary.
    if (packages.values.every((v) => !v.isPrimary)) {
      packages[rootPackageName]!.isPrimary = true;
    }

    final primaryPackages = packages.values.where((v) => v.isPrimary).toList();

    for (var pkg in primaryPackages) {
      pkg.onlyDev = false;

      for (var primaryDep in pkg.dependencies) {
        final package = packages[primaryDep.name];
        if (package == null) continue;

        if (!primaryDep.isDevDependency) {
          updateDevOnly(primaryDep);
        }
      }
    }
  }

  void updateDevOnly(Dependency dep) {
    final package = packages[dep.name];

    if (package?.onlyDev ?? false) {
      package!.onlyDev = false;

      package.dependencies
          .where((d) => !d.isDevDependency)
          .forEach(updateDevOnly);
    }
  }

  VizRoot filter({required bool excludeDev, required bool onlyOutdated}) {
    if (!excludeDev && !onlyOutdated) return this;

    final newPackages = <String, VizPackage>{};

    VizPackage clonePackage(VizPackage pkg, {required bool includeDev}) =>
        VizPackage(
          pkg.name,
          pkg.version,
          pkg.dependencies
              .where((d) => includeDev || !d.isDevDependency)
              .toSet(),
          pkg.latestVersion,
          isPrimary: pkg.isPrimary,
        );

    if (onlyOutdated) {
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
    } else {
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
        newPackages[pkgName] = clonePackage(orig, includeDev: !excludeDev);
      }
    }

    return VizRoot(rootPackageName, newPackages)..update(false);
  }
}
