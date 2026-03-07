import 'viz_package.dart';
import 'viz_root.dart';

/// Computes the topological sort of packages that need to be updated.
///
/// A package "needs to be updated" if it has at least one dependency
/// whose version constraint does not allow the latest version of that
/// dependency.
///
/// If A depends on B, and both A and B need to be updated, B will appear
/// before A in the returned list.
List<VizPackage> computeUpdateOrder(VizRoot root) {
  final needsUpdate = <String, VizPackage>{};

  for (final pkg in root.packages.values) {
    if (pkg.name == root.rootPackageName) continue;

    final hasOutdatedDep = pkg.dependencies.any(
      (dep) => dep.includesLatest == false,
    );

    if (hasOutdatedDep) {
      needsUpdate[pkg.name] = pkg;
    }
  }

  if (needsUpdate.isEmpty) return [];

  final sorted = <VizPackage>[];
  final visited = <String>{};
  final visiting = <String>{};

  void visit(VizPackage pkg) {
    if (visited.contains(pkg.name)) return;
    if (visiting.contains(pkg.name)) return;

    visiting.add(pkg.name);

    for (final dep in pkg.dependencies) {
      final depPkg = needsUpdate[dep.name];
      if (depPkg != null) {
        visit(depPkg);
      }
    }

    visiting.remove(pkg.name);
    visited.add(pkg.name);
    sorted.add(pkg);
  }

  for (final pkg in needsUpdate.values) {
    visit(pkg);
  }

  return sorted;
}
