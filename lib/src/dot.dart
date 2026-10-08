import 'package:gviz/gviz.dart';

import 'colors.dart';
import 'dependency.dart';
import 'util.dart';
import 'viz_package.dart';
import 'viz_root.dart';

extension VizRootExt on VizRoot {
  String toDot({Iterable<String> ignorePackages = const []}) {
    final gviz = Gviz(
      name: 'pubviz',
      graphProperties: {'nodesep': '0.2'},
      edgeProperties: {'fontcolor': 'gray'},
    );

    final ignored = ignorePackages.toSet();
    for (final pack in renderablePackages(this, ignored)) {
      gviz.addBlankLine();
      final isRoot = root.name == pack.name;
      gviz.addNode(
        pack.name,
        properties: _nodeProperties(
          pack,
          isRoot: isRoot,
          isWorkspace: isWorkspace,
        ),
      );

      final orderedDeps =
          pack.dependencies
              .where((d) => !ignored.contains(d.name))
              .toList(growable: false)
            ..sort();

      for (final dep in orderedDeps) {
        if (!dep.isDevDependency || isRoot || pack.isPrimary) {
          gviz.addEdge(
            pack.name,
            dep.name,
            properties: _edgeProperties(pack, dep, rootName: root.name),
          );
        }
      }
    }

    return gviz.toString();
  }
}

Map<String, String> _nodeProperties(
  VizPackage pkg, {
  required bool isRoot,
  required bool isWorkspace,
}) {
  final label = formatNodeLabel(
    pkg,
    isRoot: isRoot,
    isWorkspace: isWorkspace,
    lineBreak: r'\n',
  );

  final props = {'label': label};

  if (isRoot) {
    props['style'] = 'bold';
  }

  if (!pkg.onlyDev) {
    props['shape'] = 'box';
    props['margin'] = '0.25,0.15';
  }

  if (pkg.isPrimary) {
    props['style'] = 'filled,bold';
    props['color'] = colorPrimary;
    props['fillcolor'] = colorBackgroundPrimary;
  }

  if (pkg.isPublishToNone) {
    final currentStyle = props['style'];
    props['style'] = currentStyle == null ? 'dashed' : '$currentStyle,dashed';
  }

  if (!isRoot && pkg.isOutdated) {
    props['color'] = colorRed;
    props['xlabel'] = '${pkg.latestVersion}';
  }

  return props;
}

Map<String, String> _edgeProperties(
  VizPackage pkg,
  Dependency dep, {
  required String rootName,
}) {
  final isRoot = rootName == pkg.name;
  final edgeProps = <String, String>{};

  if (!dep.versionConstraint.isAny) {
    edgeProps['label'] = '${dep.versionConstraint}';
  }

  if (isRoot) {
    edgeProps['penwidth'] = '2';
  }

  if (dep.isDevDependency) {
    edgeProps['style'] = 'dashed';
  } else if (pkg.onlyDev) {
    edgeProps['color'] = 'gray';
  }

  if (dep.includesLatest == false) {
    edgeProps['fontcolor'] = colorRed;
    edgeProps['color'] = edgeProps['color'] == 'gray' ? colorPink : colorRed;
  }

  if (dep.name == rootName) {
    // If a package depends on the root node, it should not affect layout
    edgeProps['constraint'] = 'false';
  }

  return edgeProps;
}
