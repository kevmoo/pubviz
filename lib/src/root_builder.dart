import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';
import 'service.dart';
import 'viz_root.dart';

extension ServiceVizRootExt on Service {
  Future<VizRoot> vizRoot({
    bool flagOutdated = false,
    Iterable<String>? ignorePackages,
    bool directDependenciesOnly = false,
    bool productionDependenciesOnly = false,
    bool includeWorkspace = false,
  }) async {
    final rootPubspec = this.rootPubspec();

    final packages = await getReferencedPackages(
      flagOutdated,
      directDependenciesOnly,
      productionDependenciesOnly,
      includeWorkspace: includeWorkspace,
    );

    final value = VizRoot(rootPubspec.name, packages)..update(includeWorkspace);

    if (flagOutdated) {
      for (var dep in _allDeps(value, ignorePackages)) {
        assert(dep.includesLatest == null);

        final package = packages[dep.name];

        if (package != null &&
            package.latestVersion != null &&
            dep.versionConstraint != VersionConstraint.empty) {
          var allowsLatest = dep.versionConstraint.allows(
            package.latestVersion!,
          );

          if (!allowsLatest) {
            // it could be that the versionConstraint is actually *ahead* of
            // latest – with a pre-release version
            final constraint = dep.versionConstraint;
            if (constraint is VersionRange) {
              final min = constraint.min;
              if (min != null && min.compareTo(package.latestVersion!) > 0) {
                allowsLatest = true;
              }
            }
          }

          dep.includesLatest = allowsLatest;
        }
      }
    }

    return value;
  }
}

Iterable<Dependency> _allDeps(
  VizRoot root,
  Iterable<String>? ignorePackages,
) sync* {
  ignorePackages ??= const [];
  for (var pkg in root.packages.values.where(
    (v) => !ignorePackages!.contains(v.name),
  )) {
    yield* pkg.dependencies;
  }
}
