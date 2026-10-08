import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

import 'converters.dart';
import 'dependency.dart';
import 'viz_package.dart';

part 'viz_root.g.dart';

@JsonSerializable(includeIfNull: false)
class VizRoot {
  final String rootPackageName;
  final Map<String, VizPackage> packages;

  @FalseNullConverter()
  final bool isWorkspace;

  late final VizPackage root = packages[rootPackageName]!;

  late final bool hasOutdated = packages.values.any((p) => p.isOutdated);

  late final bool hasDevDependencies = packages.values.any(
    (p) => p.dependencies.any((d) => d.isDevDependency),
  );

  late final bool hasIsolatedPackages = () {
    final reachable = _reachableFromPublished(rootPackageName, packages);
    return packages.keys.any((name) => !reachable.contains(name));
  }();

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
        final includesLatest = flagOutdated && !skipOutdated
            ? _computeIncludesLatest(dep, packages[dep.name])
            : null;
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

  static bool? _computeIncludesLatest(Dependency dep, VizPackage? depPackage) {
    final latestVersion = depPackage?.latestVersion;
    final constraint = dep.versionConstraint;
    if (latestVersion == null || constraint == VersionConstraint.empty) {
      return null;
    }
    if (constraint.allows(latestVersion)) {
      return true;
    }
    if (constraint case VersionRange(:final min?)
        when min.isPreRelease && min.compareTo(latestVersion) > 0) {
      return true;
    }
    return false;
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
      currentPackages = _rebuildPackages(
        currentPackages,
        currentPackages.keys.where(
          (k) => k == rootPackageName || !ignored.contains(k),
        ),
        includeDep: (d) => !ignored.contains(d.name),
      );
    }
    if (onlyWorkspace) {
      currentPackages = _filterWorkspace(currentPackages, excludeDev);
    }
    if (onlyOutdated) {
      currentPackages = _filterOutdated(currentPackages, excludeDev);
    }
    if (!onlyWorkspace && !onlyOutdated) {
      final keepNodes = _reachableFromRoots(
        currentPackages,
        excludeDev: excludeDev,
      );
      currentPackages = _rebuildPackages(
        currentPackages,
        keepNodes,
        includeDep: (d) => !excludeDev || !d.isDevDependency,
      );
    }

    if (hideIsolated && isWorkspace) {
      final keepNodes = _reachableFromPublished(
        rootPackageName,
        currentPackages,
      );
      currentPackages = _rebuildPackages(
        currentPackages,
        keepNodes,
        includeDep: (d) =>
            keepNodes.contains(d.name) && currentPackages.containsKey(d.name),
      );
    }

    return VizRoot.assemble(
      rootPackageName,
      currentPackages,
      flagOutdated: packages.values.any((p) => p.latestVersion != null),
      isWorkspace: isWorkspace,
      ignorePackages: ignorePackages,
    );
  }

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
