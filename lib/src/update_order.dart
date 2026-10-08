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
  final needsUpdate = {
    for (final pkg in root.packages.values)
      if (pkg.name != root.rootPackageName &&
          pkg.dependencies.any((dep) => dep.includesLatest == false))
        pkg.name: pkg,
  };

  if (needsUpdate.isEmpty) return [];

  final sorted = <VizPackage>[];
  final visited = <String>{};
  final visiting = <String>{};

  void visit(VizPackage pkg) {
    // We intentionally don't throw on cycle detection here.
    // Circular dependencies (especially involving dev_dependencies)
    // are common in Dart monorepos. Returning when already visiting breaks
    // the cycle gracefully and provides a best-effort topological sort.
    if (visited.contains(pkg.name) || visiting.contains(pkg.name)) return;

    visiting.add(pkg.name);

    for (final dep in pkg.dependencies) {
      if (needsUpdate[dep.name] case final depPkg?) {
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
