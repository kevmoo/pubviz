import 'package:gviz/gviz.dart';

import '../src/viz_package.dart';
import '../src/viz_root.dart';
import 'colors.dart';

String toDotHtml(
  String htmlTemplate,
  VizRoot root, {
  List<String> ignorePackages = const [],
}) {
  final dot = toDot(root, ignorePackages: ignorePackages);
  final regex = RegExp(
    r'(<script type="text/vnd\.graphviz" id="dot">)(.*?)(</script>)',
    dotAll: true,
  );
  return htmlTemplate
      .replaceFirstMapped(
        regex,
        (match) => '${match.group(1)}\n$dot\n      ${match.group(3)}',
      )
      .replaceFirst(
        RegExp(r'<title>pubviz - .*?</title>'),
        '<title>pubviz - ${root.root.name}</title>',
      );
}

String toDot(VizRoot item, {Iterable<String> ignorePackages = const []}) {
  final gviz = Gviz(
    name: 'pubviz',
    graphProperties: {'nodesep': '0.2'},
    edgeProperties: {'fontcolor': 'gray'},
  );

  for (var pack in item.packages.values.where(
    (v) => !ignorePackages.contains(v.name),
  )) {
    gviz.addBlankLine();
    _writeDot(pack, gviz, item.root.name, ignorePackages);
  }

  return gviz.toString();
}

void _writeDot(
  VizPackage pkg,
  Gviz gviz,
  String rootName,
  Iterable<String> ignorePackages,
) {
  final isRoot = rootName == pkg.name;

  var label = pkg.name;
  if (pkg.version != null) {
    label = '$label\\n${pkg.version}';
  }

  final props = {'label': label};

  if (isRoot) {
    assert(!pkg.onlyDev);
    props['fontsize'] = '18';
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

  if (!isRoot &&
      pkg.version != null &&
      pkg.latestVersion != null &&
      pkg.latestVersion!.compareTo(pkg.version!) > 0) {
    props['color'] = colorRed;
    props['xlabel'] = '${pkg.latestVersion}';
  }

  gviz.addNode(pkg.name, properties: props);

  final orderedDeps = pkg.dependencies.toList(growable: false)..sort();

  for (var dep in orderedDeps.where((d) => !ignorePackages.contains(d.name))) {
    if (!dep.isDevDependency || isRoot) {
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

      if (dep.includesLatest != null && !dep.includesLatest!) {
        edgeProps['fontcolor'] = colorRed;
        if (edgeProps['color'] == 'gray') {
          edgeProps['color'] = colorPink;
        } else {
          edgeProps['color'] = colorRed;
        }
      }

      if (dep.name == rootName) {
        // If a package depends on the root node, it should not affect layout
        edgeProps['constraint'] = 'false';
      }

      gviz.addEdge(pkg.name, dep.name, properties: edgeProps);
    }
  }
}
