import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'converters.dart';
import 'dependency.dart';
import 'viz_package.dart';

part 'viz_root.g.dart';

@JsonSerializable(includeIfNull: false)
class VizRoot with HasPackages {
  @override
  final String rootPackageName;
  @override
  final Map<String, VizPackage> packages;

  @FalseNullConverter()
  final bool isWorkspace;

  VizRoot(
    this.rootPackageName,
    Map<String, VizPackage> packages, {
    this.isWorkspace = false,
  }) : packages = UnmodifiableMapView(packages);

  factory VizRoot.fromJson(Map<String, dynamic> json) =>
      _$VizRootFromJson(json);

  Map<String, dynamic> toJson() => _$VizRootToJson(this);

  static VizRoot assemble(
    String rootPackageName,
    Map<String, VizPackage> packages, {
    bool flagOutdated = false,
    Iterable<String>? ignorePackages,
    bool isWorkspace = false,
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

    final newPackages = SplayTreeMap<String, VizPackage>();
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
        isPublishToNone: pkg.isPublishToNone,
      );
    }

    return VizRoot(rootPackageName, newPackages, isWorkspace: isWorkspace);
  }

  VizRoot filter({
    bool excludeDev = false,
    bool onlyOutdated = false,
    bool onlyWorkspace = false,
    bool hideIsolatedWorkspacePackages = false,
  }) {
    if (!excludeDev &&
        !onlyOutdated &&
        !onlyWorkspace &&
        !hideIsolatedWorkspacePackages) {
      return this;
    }

    var currentPackages = packages;
    if (onlyWorkspace) {
      currentPackages = _filterWorkspace(currentPackages, excludeDev);
    }
    if (onlyOutdated) {
      currentPackages = _filterOutdated(currentPackages, excludeDev);
    }
    if (!onlyWorkspace && !onlyOutdated) {
      currentPackages = _filterStandard(currentPackages, excludeDev);
    }

    if (hideIsolatedWorkspacePackages && isWorkspace) {
      currentPackages = _filterIsolatedWorkspacePackages(currentPackages);
    }

    return VizRoot.assemble(
      rootPackageName,
      currentPackages,
      flagOutdated: packages.values.any((p) => p.latestVersion != null),
      isWorkspace: isWorkspace,
    );
  }

  Map<String, VizPackage> _filterWorkspace(
    Map<String, VizPackage> sourcePackages,
    bool excludeDev,
  ) {
    final primaryNodes = sourcePackages.values
        .where((p) => p.isPrimary)
        .map((p) => p.name)
        .toSet();

    // 1. Forward Reachable from Primary
    final forwardReachable = <String>{...primaryNodes};
    final queue = primaryNodes.toList();
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final pkg = sourcePackages[current];
      if (pkg != null) {
        for (var dep in pkg.dependencies) {
          if (excludeDev && dep.isDevDependency) continue;
          if (forwardReachable.add(dep.name)) {
            queue.add(dep.name);
          }
        }
      }
    }

    // 2. Build Incoming Edges (only for forward reachable nodes to save time)
    final incoming = <String, Set<String>>{};
    for (var name in forwardReachable) {
      final pkg = sourcePackages[name];
      if (pkg != null) {
        for (var dep in pkg.dependencies) {
          if (excludeDev && dep.isDevDependency) continue;
          incoming.putIfAbsent(dep.name, () => {}).add(name);
        }
      }
    }

    // 3. Backward Reachable to Primary
    final backwardReachable = <String>{...primaryNodes};
    final backQueue = primaryNodes.toList();
    while (backQueue.isNotEmpty) {
      final current = backQueue.removeLast();
      for (var parent in incoming[current] ?? <String>{}) {
        if (backwardReachable.add(parent)) {
          backQueue.add(parent);
        }
      }
    }

    // 4. Intersection
    final keepNodes = forwardReachable.intersection(backwardReachable);

    final newPackages = SplayTreeMap<String, VizPackage>();
    for (var name in keepNodes) {
      final orig = sourcePackages[name];
      if (orig != null) {
        final filteredDeps = orig.dependencies
            .where((d) => keepNodes.contains(d.name))
            .where((d) => !(excludeDev && d.isDevDependency))
            .toSet();

        newPackages[name] = VizPackage(
          orig.name,
          orig.version,
          filteredDeps,
          orig.latestVersion,
          isPrimary: orig.isPrimary,
          onlyDev: orig.onlyDev,
          isPublishToNone: orig.isPublishToNone,
        );
      }
    }

    return newPackages;
  }

  Map<String, VizPackage> _filterOutdated(
    Map<String, VizPackage> sourcePackages,
    bool excludeDev,
  ) {
    final newPackages = SplayTreeMap<String, VizPackage>();
    final primaryPackages = sourcePackages.values
        .where((p) => p.isPrimary)
        .map((p) => p.name)
        .toList();
    final reachableFromRoot = <String>{...primaryPackages, rootPackageName};
    final rootQueue = <String>[...reachableFromRoot];
    while (rootQueue.isNotEmpty) {
      final current = rootQueue.removeLast();
      final orig = sourcePackages[current];
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
      final pkg = sourcePackages[pkgName];
      if (pkg != null) {
        for (var dep in pkg.dependencies) {
          if (excludeDev && dep.isDevDependency) continue;
          incoming.putIfAbsent(dep.name, () => {}).add(pkg.name);
        }
      }
    }

    final outdatedNodes = reachableFromRoot.where((name) {
      final p = sourcePackages[name];
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
      final orig = sourcePackages[pkgName];
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
          onlyDev: orig.onlyDev,
          isPublishToNone: orig.isPublishToNone,
        );
      }
    }
    return newPackages;
  }

  Map<String, VizPackage> _filterStandard(
    Map<String, VizPackage> sourcePackages,
    bool excludeDev,
  ) {
    final newPackages = SplayTreeMap<String, VizPackage>();
    final primaryPackages = sourcePackages.values
        .where((p) => p.isPrimary)
        .map((p) => p.name)
        .toList();
    final keepNodes = <String>{...primaryPackages, rootPackageName};
    final queue = <String>[...keepNodes];

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      final orig = sourcePackages[current];
      if (orig == null) continue;

      for (var dep in orig.dependencies) {
        if (excludeDev && dep.isDevDependency) continue;

        if (keepNodes.add(dep.name)) {
          queue.add(dep.name);
        }
      }
    }

    for (var pkgName in keepNodes) {
      final orig = sourcePackages[pkgName];
      if (orig == null) continue;

      newPackages[pkgName] = VizPackage(
        orig.name,
        orig.version,
        orig.dependencies
            .where((d) => !excludeDev || !d.isDevDependency)
            .toSet(),
        orig.latestVersion,
        isPrimary: orig.isPrimary,
        onlyDev: orig.onlyDev,
        isPublishToNone: orig.isPublishToNone,
      );
    }
    return newPackages;
  }

  Map<String, VizPackage> _filterIsolatedWorkspacePackages(
    Map<String, VizPackage> sourcePackages,
  ) {
    final incoming = <String>{};
    for (final pkg in sourcePackages.values) {
      for (final dep in pkg.dependencies) {
        incoming.add(dep.name);
      }
    }

    final keepNodes = sourcePackages.keys.where((name) {
      final pkg = sourcePackages[name];
      if (pkg == null) return false;
      final hasIncoming = incoming.contains(name);

      // We keep a package in the graph if:
      // 1. It is the root package (we never want to hide the entry point).
      // 2. It is a published package
      //    (we only want to hide internal workspace bits).
      // 3. It has incoming dependencies (it is not isolated).
      return name == rootPackageName || !pkg.isPublishToNone || hasIncoming;
    }).toSet();

    final newPackages = SplayTreeMap<String, VizPackage>();
    for (final name in keepNodes) {
      final orig = sourcePackages[name];
      if (orig == null) continue;
      final filteredDeps = orig.dependencies
          .where((d) => keepNodes.contains(d.name))
          .toSet();

      newPackages[name] = VizPackage(
        orig.name,
        orig.version,
        filteredDeps,
        orig.latestVersion,
        isPrimary: orig.isPrimary,
        onlyDev: orig.onlyDev,
        isPublishToNone: orig.isPublishToNone,
      );
    }
    return newPackages;
  }
}

abstract mixin class HasPackages {
  String get rootPackageName;
  Map<String, VizPackage> get packages;

  late final root =
      packages[rootPackageName] ?? VizPackage(rootPackageName, null, {}, null);

  late final hasOutdated = packages.values.any(
    (p) =>
        p.version != null &&
        p.latestVersion != null &&
        p.latestVersion!.compareTo(p.version!) > 0,
  );

  late final hasDevDependencies = packages.values.any(
    (p) => p.dependencies.any((d) => d.isDevDependency),
  );
}
