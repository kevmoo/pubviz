import 'viz_package.dart';
import 'viz_root.dart';

String formatNodeLabel(
  VizPackage pkg, {
  required bool isWorkspace,
  required bool isRoot,
  required String lineBreak,
}) {
  var label = pkg.name;
  if (isWorkspace && isRoot) {
    label = '⚙️ $label';
  }
  if (pkg.version != null) {
    label = '$label$lineBreak${pkg.version}';
  }
  return label;
}

List<VizPackage> renderablePackages(
  VizRoot root,
  Iterable<String> ignorePackages,
) {
  final ignored = ignorePackages.toSet();
  final list = root.packages.values
      .where((v) => !ignored.contains(v.name))
      .toList(growable: false);

  if (!root.isWorkspace || list.length <= 1) {
    return list;
  }

  final rootPkg = root.root;
  if (!rootPkg.isPublishToNone) {
    return list;
  }

  final hasOutgoing = rootPkg.dependencies.any(
    (d) => !ignored.contains(d.name),
  );
  if (hasOutgoing) {
    return list;
  }

  final hasIncoming = list.any(
    (p) =>
        p.name != rootPkg.name &&
        p.dependencies.any(
          (d) => d.name == rootPkg.name && (!d.isDevDependency || p.isPrimary),
        ),
  );
  if (hasIncoming) {
    return list;
  }

  return list.where((p) => p.name != rootPkg.name).toList(growable: false);
}
