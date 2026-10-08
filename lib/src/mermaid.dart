import 'dependency.dart';
import 'util.dart';
import 'viz_package.dart';
import 'viz_root.dart';

typedef _MermaidStyleLists = ({
  List<String> primaryNodes,
  List<String> outdatedNodes,
  List<String> publishToNoneNodes,
  List<int> onlyDevLinks,
  List<int> outdatedLinks,
  List<int> outdatedDevLinks,
});

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

    final styles = (
      primaryNodes: <String>[],
      outdatedNodes: <String>[],
      publishToNoneNodes: <String>[],
      onlyDevLinks: <int>[],
      outdatedLinks: <int>[],
      outdatedDevLinks: <int>[],
    );

    for (final pkg in visiblePackages) {
      _writeNode(sb, pkg, this, styles);
    }

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
        _classifyEdge(pkg, dep, edgeIndex++, styles);
      }
    }

    _writeClassesAndStyles(sb, styles);

    return sb.toString();
  }
}

void _writeNode(
  StringBuffer sb,
  VizPackage pkg,
  VizRoot vizRoot,
  _MermaidStyleLists styles,
) {
  final isRoot = vizRoot.root.name == pkg.name;
  var label = formatNodeLabel(
    pkg,
    isRoot: isRoot,
    isWorkspace: vizRoot.isWorkspace,
    lineBreak: '<br/>',
  );

  if (!isRoot && pkg.isOutdated) {
    label = '$label<br/>(latest: ${pkg.latestVersion})';
    styles.outdatedNodes.add(pkg.name);
  }
  if (pkg.isPrimary) {
    styles.primaryNodes.add(pkg.name);
  }
  if (pkg.isPublishToNone) {
    styles.publishToNoneNodes.add(pkg.name);
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
  int edgeIndex,
  _MermaidStyleLists styles,
) {
  final isOutdatedEdge = dep.includesLatest == false;
  final isGrayEdge = !dep.isDevDependency && pkg.onlyDev;

  if (isOutdatedEdge) {
    (isGrayEdge ? styles.outdatedDevLinks : styles.outdatedLinks).add(
      edgeIndex,
    );
  } else if (isGrayEdge) {
    styles.onlyDevLinks.add(edgeIndex);
  }
}

void _writeClassesAndStyles(StringBuffer sb, _MermaidStyleLists styles) {
  if (styles.primaryNodes.isNotEmpty) {
    sb.writeln('  class ${styles.primaryNodes.join(',')} primary;');
  }
  if (styles.outdatedNodes.isNotEmpty) {
    sb.writeln('  class ${styles.outdatedNodes.join(',')} outdated;');
  }
  if (styles.publishToNoneNodes.isNotEmpty) {
    sb.writeln('  class ${styles.publishToNoneNodes.join(',')} publishToNone;');
  }
  if (styles.onlyDevLinks.isNotEmpty) {
    sb.writeln(
      '  linkStyle ${styles.onlyDevLinks.join(',')} '
      'stroke:#9e9e9e,color:#9e9e9e;',
    );
  }
  if (styles.outdatedLinks.isNotEmpty) {
    sb.writeln(
      '  linkStyle ${styles.outdatedLinks.join(',')} '
      'stroke:#e53935,color:#e53935,stroke-width:2px;',
    );
  }
  if (styles.outdatedDevLinks.isNotEmpty) {
    sb.writeln(
      '  linkStyle ${styles.outdatedDevLinks.join(',')} '
      'stroke:#f48fb1,color:#e53935,stroke-width:2px;',
    );
  }
}
