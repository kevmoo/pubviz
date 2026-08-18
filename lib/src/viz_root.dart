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
  }) : assert(packages.containsKey(rootPackageName)),
       packages = UnmodifiableMapView(packages);

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
    var primaryPackageNames = _primaryPackageNames(packages);
    if (primaryPackageNames.isEmpty) {
      primaryPackageNames = {rootPackageName};
    }

    final nonDevReachable = _reachable(
      primaryPackageNames,
      (pkg) => packages[pkg]?.dependencies
          .where((d) => !d.isDevDependency)
          .map((d) => d.name),
    );

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
    bool hideIsolated = false,
    Iterable<String> ignorePackages = const [],
  }) {
    final ignored = ignorePackages.toSet();
    if (!excludeDev &&
        !onlyOutdated &&
        !onlyWorkspace &&
        !hideIsolated &&
        ignored.isEmpty) {
      return this;
    }

    var currentPackages = packages;
    if (ignored.isNotEmpty) {
      currentPackages = _filterIgnored(currentPackages, ignored);
    }
    if (onlyWorkspace) {
      currentPackages = _filterWorkspace(currentPackages, excludeDev);
    }
    if (onlyOutdated) {
      currentPackages = _filterOutdated(currentPackages, excludeDev);
    }
    if (!onlyWorkspace && !onlyOutdated) {
      currentPackages = _filterStandard(currentPackages, excludeDev);
    }

    if (hideIsolated && isWorkspace) {
      currentPackages = _filterIsolated(currentPackages);
    }

    return VizRoot.assemble(
      rootPackageName,
      currentPackages,
      flagOutdated: packages.values.any((p) => p.latestVersion != null),
      isWorkspace: isWorkspace,
      ignorePackages: ignorePackages,
    );
  }

  Map<String, VizPackage> _filterIgnored(
    Map<String, VizPackage> sourcePackages,
    Set<String> ignored,
  ) => _rebuildPackages(
    sourcePackages,
    sourcePackages.keys.where(
      (k) => k == rootPackageName || !ignored.contains(k),
    ),
    includeDep: (d) => !ignored.contains(d.name),
  );

  Map<String, VizPackage> _filterWorkspace(
    Map<String, VizPackage> sourcePackages,
    bool excludeDev,
  ) {
    final primaryNodes = _primaryPackageNames(sourcePackages);

    // 1. Forward Reachable from Primary
    final forwardReachable = _reachable(
      primaryNodes,
      (pkg) => sourcePackages[pkg]?.dependencies
          .where((d) => !excludeDev || !d.isDevDependency)
          .map((d) => d.name),
    );

    // 2. Build Incoming Edges (only for forward reachable nodes to save time)
    final incoming = _buildIncoming(
      sourcePackages,
      forwardReachable,
      excludeDev: excludeDev,
    );

    // 3. Backward Reachable to Primary
    final backwardReachable = _reachable(primaryNodes, (pkg) => incoming[pkg]);

    // 4. Intersection
    final keepNodes = forwardReachable.intersection(backwardReachable);

    return _rebuildPackages(
      sourcePackages,
      keepNodes,
      includeDep: (d) =>
          keepNodes.contains(d.name) && !(excludeDev && d.isDevDependency),
    );
  }

  Map<String, VizPackage> _filterOutdated(
    Map<String, VizPackage> sourcePackages,
    bool excludeDev,
  ) {
    final reachableFromRoot = _reachableFromRoots(
      sourcePackages,
      excludeDev: excludeDev,
    );

    final incoming = _buildIncoming(
      sourcePackages,
      reachableFromRoot,
      excludeDev: excludeDev,
    );

    final outdatedNodes = reachableFromRoot.where((name) {
      final p = sourcePackages[name];
      return p != null && p.isOutdated;
    }).toSet();

    final keepNodes = _reachable(outdatedNodes, (pkg) => incoming[pkg])
      ..add(rootPackageName);

    return _rebuildPackages(
      sourcePackages,
      keepNodes,
      includeDep: (d) =>
          keepNodes.contains(d.name) && (!excludeDev || !d.isDevDependency),
    );
  }

  Map<String, VizPackage> _filterStandard(
    Map<String, VizPackage> sourcePackages,
    bool excludeDev,
  ) {
    final keepNodes = _reachableFromRoots(
      sourcePackages,
      excludeDev: excludeDev,
    );

    return _rebuildPackages(
      sourcePackages,
      keepNodes,
      includeDep: (d) => !excludeDev || !d.isDevDependency,
    );
  }

  Map<String, VizPackage> _filterIsolated(
    Map<String, VizPackage> sourcePackages,
  ) {
    final keepNodes = _reachableFromPublished(rootPackageName, sourcePackages);
    return _rebuildPackages(
      sourcePackages,
      keepNodes,
      includeDep: (d) =>
          keepNodes.contains(d.name) && sourcePackages.containsKey(d.name),
    );
  }

  static Set<String> _primaryPackageNames(Map<String, VizPackage> packages) =>
      packages.values.where((p) => p.isPrimary).map((p) => p.name).toSet();

  Set<String> _reachableFromRoots(
    Map<String, VizPackage> sourcePackages, {
    required bool excludeDev,
  }) {
    final seeds = [..._primaryPackageNames(sourcePackages), rootPackageName];
    return _reachable(
      seeds,
      (pkg) => sourcePackages[pkg]?.dependencies
          .where((d) => !excludeDev || !d.isDevDependency)
          .map((d) => d.name),
    );
  }

  static Map<String, Set<String>> _buildIncoming(
    Map<String, VizPackage> sourcePackages,
    Iterable<String> nodes, {
    required bool excludeDev,
  }) {
    final incoming = <String, Set<String>>{};
    for (var name in nodes) {
      final pkg = sourcePackages[name];
      if (pkg != null) {
        for (var dep in pkg.dependencies) {
          if (excludeDev && dep.isDevDependency) continue;
          incoming.putIfAbsent(dep.name, () => {}).add(name);
        }
      }
    }
    return incoming;
  }

  static Map<String, VizPackage> _rebuildPackages(
    Map<String, VizPackage> sourcePackages,
    Iterable<String> keepNodes, {
    required bool Function(Dependency dep) includeDep,
  }) {
    final newPackages = SplayTreeMap<String, VizPackage>();
    for (var name in keepNodes) {
      final orig = sourcePackages[name];
      if (orig != null) {
        final filteredDeps = orig.dependencies.where(includeDep).toSet();
        newPackages[name] = orig.withDependencies(filteredDeps);
      }
    }
    return newPackages;
  }
}

abstract mixin class HasPackages {
  String get rootPackageName;
  Map<String, VizPackage> get packages;

  late final root = packages[rootPackageName]!;

  late final hasOutdated = packages.values.any((p) => p.isOutdated);

  late final hasDevDependencies = packages.values.any(
    (p) => p.dependencies.any((d) => d.isDevDependency),
  );

  late final hasIsolatedPackages = () {
    final reachable = _reachableFromPublished(rootPackageName, packages);
    return packages.keys.any((name) => !reachable.contains(name));
  }();
}

Set<String> _reachableFromPublished(
  String rootPackageName,
  Map<String, VizPackage> packages,
) {
  final seeds = <String>{
    rootPackageName,
    for (final pkg in packages.values)
      if (!pkg.isPublishToNone) pkg.name,
  };
  return _reachable(
    seeds,
    (pkg) => packages[pkg]?.dependencies.map((d) => d.name),
  );
}

Set<String> _reachable(
  Iterable<String> seeds,
  Iterable<String>? Function(String node) getNeighbors,
) {
  final visited = <String>{...seeds};
  final queue = seeds.toList();
  while (queue.isNotEmpty) {
    final current = queue.removeLast();
    final neighbors = getNeighbors(current);
    if (neighbors != null) {
      for (final next in neighbors) {
        if (visited.add(next)) {
          queue.add(next);
        }
      }
    }
  }
  return visited;
}
