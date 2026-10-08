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
    final styles = _MermaidStyles();

    for (final pkg in visiblePackages) {
      final isRoot = root.name == pkg.name;
      _writeNode(sb, pkg, isRoot: isRoot, isWorkspace: isWorkspace);
      styles.addNode(pkg, isRoot: isRoot);
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
        styles.addEdge(pkg, dep, edgeIndex++);
      }
    }

    styles.write(sb);

    return sb.toString();
  }
}

void _writeNode(
  StringBuffer sb,
  VizPackage pkg, {
  required bool isRoot,
  required bool isWorkspace,
}) {
  var label = formatNodeLabel(
    pkg,
    isRoot: isRoot,
    isWorkspace: isWorkspace,
    lineBreak: '<br/>',
  );
  if (!isRoot && pkg.isOutdated) {
    label = '$label<br/>(latest: ${pkg.latestVersion})';
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

/// Collects the node classes and link styles emitted after the graph body.
final class _MermaidStyles {
  final _primaryNodes = <String>[];
  final _outdatedNodes = <String>[];
  final _publishToNoneNodes = <String>[];
  final _onlyDevLinks = <int>[];
  final _outdatedLinks = <int>[];
  final _outdatedDevLinks = <int>[];

  void addNode(VizPackage pkg, {required bool isRoot}) {
    if (!isRoot && pkg.isOutdated) _outdatedNodes.add(pkg.name);
    if (pkg.isPrimary) _primaryNodes.add(pkg.name);
    if (pkg.isPublishToNone) _publishToNoneNodes.add(pkg.name);
  }

  void addEdge(VizPackage pkg, Dependency dep, int edgeIndex) {
    final isOutdatedEdge = dep.includesLatest == false;
    final isGrayEdge = !dep.isDevDependency && pkg.onlyDev;

    if (isOutdatedEdge) {
      (isGrayEdge ? _outdatedDevLinks : _outdatedLinks).add(edgeIndex);
    } else if (isGrayEdge) {
      _onlyDevLinks.add(edgeIndex);
    }
  }

  void write(StringSink sink) {
    _writeClass(sink, _primaryNodes, 'primary');
    _writeClass(sink, _outdatedNodes, 'outdated');
    _writeClass(sink, _publishToNoneNodes, 'publishToNone');
    _writeLinkStyle(sink, _onlyDevLinks, 'stroke:#9e9e9e,color:#9e9e9e;');
    _writeLinkStyle(
      sink,
      _outdatedLinks,
      'stroke:#e53935,color:#e53935,stroke-width:2px;',
    );
    _writeLinkStyle(
      sink,
      _outdatedDevLinks,
      'stroke:#f48fb1,color:#e53935,stroke-width:2px;',
    );
  }

  static void _writeClass(StringSink sink, List<String> nodes, String name) {
    if (nodes.isNotEmpty) sink.writeln('  class ${nodes.join(',')} $name;');
  }

  static void _writeLinkStyle(StringSink sink, List<int> links, String style) {
    if (links.isNotEmpty) sink.writeln('  linkStyle ${links.join(',')} $style');
  }
}
