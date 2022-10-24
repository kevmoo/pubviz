import 'dart:async';
import 'dart:collection';

import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';
import 'service.dart';
import 'viz_package.dart';

class VizRoot {
  final String rootPackageName;
  final Map<String, VizPackage> packages;

  VizRoot._(this.rootPackageName, Map<String, VizPackage> packages)
      : assert(packages.containsKey(rootPackageName)),
        packages = UnmodifiableMapView(packages);

  VizPackage get root => packages[rootPackageName]!;

  static Future<VizRoot> forDirectory(
    Service service, {
    bool flagOutdated = false,
    Iterable<String>? ignorePackages,
    bool directDependenciesOnly = false,
    bool productionDependenciesOnly = false,
  }) async {
    final rootPubspec = service.rootPubspec();

    final packages = await service.getReferencedPackages(
      flagOutdated,
      directDependenciesOnly,
      productionDependenciesOnly,
    );

    final value = VizRoot._(rootPubspec.name, packages).._update();

    if (flagOutdated) {
      for (var dep in _allDeps(value, ignorePackages)) {
        assert(dep.includesLatest == null);

        final package = packages[dep.name];

        if (package != null &&
            package.latestVersion != null &&
            dep.versionConstraint != VersionConstraint.empty) {
          var allowsLatest =
              dep.versionConstraint.allows(package.latestVersion!);

          if (!allowsLatest) {
            // it could be that the versionConstraint is actually *ahead* of
            // latest – with a pre-release version

            // TODO: get rid of the `as` here – this is weird!
            final constraintAsRange = dep.versionConstraint as VersionRange;
            if (package.latestVersion!.compareTo(constraintAsRange) < 0) {
              allowsLatest = true;
            }
          }

          dep.includesLatest = allowsLatest;
        }
      }
    }

    return value;
  }

  void _update() {
    if (root.isPrimary == false) {
      root.isPrimary = true;

      assert(root.onlyDev);
      root.onlyDev = false;

      for (var primaryDep in root.dependencies) {
        final package = packages[primaryDep.name];
        if (package == null) continue;

        assert(!package.isPrimary);
        package.isPrimary = true;

        if (!primaryDep.isDevDependency) {
          _updateDevOnly(primaryDep);
        }
      }
    }
  }

  void _updateDevOnly(Dependency dep) {
    final package = packages[dep.name];

    if (package?.onlyDev ?? false) {
      package!.onlyDev = false;

      package.dependencies
          .where((d) => !d.isDevDependency)
          .forEach(_updateDevOnly);
    }
  }
}

Iterable<Dependency> _allDeps(
  VizRoot root,
  Iterable<String>? ignorePackages,
) sync* {
  ignorePackages ??= const [];
  for (var pkg
      in root.packages.values.where((v) => !ignorePackages!.contains(v.name))) {
    yield* pkg.dependencies;
  }
}
