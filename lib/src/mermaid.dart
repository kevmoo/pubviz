import 'viz_root.dart';

extension VizRootMermaidExt on VizRoot {
  String toMermaid({Iterable<String> ignorePackages = const []}) {
    final ignored = ignorePackages.toSet();
    final sb = StringBuffer()
      ..writeln('flowchart TD')
      ..writeln(
        '  classDef primary fill:#e3f2fd,stroke:#0175C2,stroke-width:2px;',
      )
      ..writeln('  classDef outdated stroke:#e53935,stroke-width:2px;')
      ..writeln('  classDef publishToNone stroke-dasharray: 5 5;');

    final primaryNodes = <String>[];
    final outdatedNodes = <String>[];
    final publishToNoneNodes = <String>[];

    for (final pkg in packages.values.where((v) => !ignored.contains(v.name))) {
      final isRoot = root.name == pkg.name;

      var label = pkg.name;
      if (isWorkspace && isRoot) {
        label = '⚙️ $label';
      }
      if (pkg.version != null) {
        label = '$label<br/>${pkg.version}';
      }

      if (!isRoot &&
          pkg.version != null &&
          pkg.latestVersion != null &&
          pkg.latestVersion!.compareTo(pkg.version!) > 0) {
        label = '$label<br/>(latest: ${pkg.latestVersion})';
        outdatedNodes.add(pkg.name);
      }

      if (pkg.isPrimary) {
        primaryNodes.add(pkg.name);
      }

      if (pkg.isPublishToNone) {
        publishToNoneNodes.add(pkg.name);
      }

      final shapeOpen = pkg.onlyDev ? '(' : '[';
      final shapeClose = pkg.onlyDev ? ')' : ']';

      sb.writeln('  ${pkg.name}$shapeOpen"$label"$shapeClose');
    }

    for (final pkg in packages.values.where((v) => !ignored.contains(v.name))) {
      final isRoot = root.name == pkg.name;
      final orderedDeps = pkg.dependencies.toList(growable: false)..sort();

      for (final dep in orderedDeps.where((d) => !ignored.contains(d.name))) {
        if (!dep.isDevDependency || isRoot || pkg.isPrimary) {
          final hasConstraint = !dep.versionConstraint.isAny;
          final constraintStr = hasConstraint
              ? ' "${dep.versionConstraint}"'
              : '';

          final String link;
          if (dep.isDevDependency) {
            link = hasConstraint ? '-. "${dep.versionConstraint}" .->' : '-.->';
          } else {
            link = hasConstraint ? '--$constraintStr-->' : '-->';
          }

          sb.writeln('  ${pkg.name} $link ${dep.name}');
        }
      }
    }

    if (primaryNodes.isNotEmpty) {
      sb.writeln('  class ${primaryNodes.join(',')} primary;');
    }
    if (outdatedNodes.isNotEmpty) {
      sb.writeln('  class ${outdatedNodes.join(',')} outdated;');
    }
    if (publishToNoneNodes.isNotEmpty) {
      sb.writeln('  class ${publishToNoneNodes.join(',')} publishToNone;');
    }

    return sb.toString();
  }
}
