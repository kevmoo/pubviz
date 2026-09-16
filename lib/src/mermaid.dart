import 'dependency.dart';
import 'util.dart';
import 'viz_package.dart';
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

    final visiblePackages = renderablePackages(this, ignorePackages);

    final primaryNodes = <String>[];
    final outdatedNodes = <String>[];
    final publishToNoneNodes = <String>[];

    for (final pkg in visiblePackages) {
      final isRoot = root.name == pkg.name;
      _writeNode(
        sb,
        pkg,
        isRoot: isRoot,
        isWorkspace: isWorkspace,
        primaryNodes: primaryNodes,
        outdatedNodes: outdatedNodes,
        publishToNoneNodes: publishToNoneNodes,
      );
    }

    final outdatedLinks = <int>[];
    final outdatedDevLinks = <int>[];
    final onlyDevLinks = <int>[];
    var edgeIndex = 0;

    for (final pkg in visiblePackages) {
      final isRoot = root.name == pkg.name;
      final orderedDeps =
          pkg.dependencies
              .where((d) => !ignored.contains(d.name))
              .toList(growable: false)
            ..sort();

      for (final dep in orderedDeps) {
        if (dep.isDevDependency && !isRoot && !pkg.isPrimary) continue;

        sb.writeln('  ${pkg.name} ${_formatLink(dep)} ${dep.name}');
        _classifyEdge(
          pkg,
          dep,
          edgeIndex++,
          outdatedLinks: outdatedLinks,
          outdatedDevLinks: outdatedDevLinks,
          onlyDevLinks: onlyDevLinks,
        );
      }
    }

    _writeClassesAndStyles(
      sb,
      primaryNodes: primaryNodes,
      outdatedNodes: outdatedNodes,
      publishToNoneNodes: publishToNoneNodes,
      onlyDevLinks: onlyDevLinks,
      outdatedLinks: outdatedLinks,
      outdatedDevLinks: outdatedDevLinks,
    );

    return sb.toString();
  }
}

void _writeNode(
  StringBuffer sb,
  VizPackage pkg, {
  required bool isRoot,
  required bool isWorkspace,
  required List<String> primaryNodes,
  required List<String> outdatedNodes,
  required List<String> publishToNoneNodes,
}) {
  var label = formatNodeLabel(
    pkg,
    isRoot: isRoot,
    isWorkspace: isWorkspace,
    lineBreak: '<br/>',
  );

  if (!isRoot && pkg.isOutdated) {
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

String _formatLink(Dependency dep) {
  final hasConstraint = !dep.versionConstraint.isAny;
  if (dep.isDevDependency) {
    return hasConstraint ? '-. "${dep.versionConstraint}" .->' : '-.->';
  }
  return hasConstraint ? '-- "${dep.versionConstraint}"-->' : '-->';
}

void _classifyEdge(
  VizPackage pkg,
  Dependency dep,
  int edgeIndex, {
  required List<int> outdatedLinks,
  required List<int> outdatedDevLinks,
  required List<int> onlyDevLinks,
}) {
  final isOutdatedEdge = dep.includesLatest == false;
  final isGrayEdge = !dep.isDevDependency && pkg.onlyDev;

  if (isOutdatedEdge) {
    (isGrayEdge ? outdatedDevLinks : outdatedLinks).add(edgeIndex);
  } else if (isGrayEdge) {
    onlyDevLinks.add(edgeIndex);
  }
}

void _writeClassesAndStyles(
  StringBuffer sb, {
  required List<String> primaryNodes,
  required List<String> outdatedNodes,
  required List<String> publishToNoneNodes,
  required List<int> onlyDevLinks,
  required List<int> outdatedLinks,
  required List<int> outdatedDevLinks,
}) {
  if (primaryNodes.isNotEmpty) {
    sb.writeln('  class ${primaryNodes.join(',')} primary;');
  }
  if (outdatedNodes.isNotEmpty) {
    sb.writeln('  class ${outdatedNodes.join(',')} outdated;');
  }
  if (publishToNoneNodes.isNotEmpty) {
    sb.writeln('  class ${publishToNoneNodes.join(',')} publishToNone;');
  }
  if (onlyDevLinks.isNotEmpty) {
    sb.writeln(
      '  linkStyle ${onlyDevLinks.join(',')} stroke:#9e9e9e,color:#9e9e9e;',
    );
  }
  if (outdatedLinks.isNotEmpty) {
    sb.writeln(
      '  linkStyle ${outdatedLinks.join(',')} '
      'stroke:#e53935,color:#e53935,stroke-width:2px;',
    );
  }
  if (outdatedDevLinks.isNotEmpty) {
    sb.writeln(
      '  linkStyle ${outdatedDevLinks.join(',')} '
      'stroke:#f48fb1,color:#e53935,stroke-width:2px;',
    );
  }
}
