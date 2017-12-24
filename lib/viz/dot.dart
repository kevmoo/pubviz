import 'package:gviz/gviz.dart';
import 'package:pubviz/pubviz.dart';

String toDotHtml(VizRoot root, {List<String> ignorePackages}) {
  var dot = toDot(root, escapeLabels: true, ignorePackages: ignorePackages);

  return _DOT_HTML_TEMPLATE
      .replaceAll(_DOT_PLACE_HOLDER, dot)
      .replaceAll(_TITLE_PLACE_HOLDER, root.root.name);
}

String toDot(VizRoot item,
    {bool escapeLabels: false, Iterable<String> ignorePackages}) {
  if (ignorePackages == null) {
    ignorePackages = const <String>[];
  }

  var gviz = new Gviz(
      name: 'pubviz',
      graphProperties: {'nodesep': '0.2'},
      edgeProperties: {'fontcolor': 'gray'});

  for (var pack
      in item.packages.values.where((v) => !ignorePackages.contains(v.name))) {
    gviz.addLine();
    _writeDot(pack, gviz, item.root.name, escapeLabels, ignorePackages);
  }

  return gviz.toString();
}

void _writeDot(VizPackage pkg, Gviz gviz, String rootName, bool escapeLabels,
    Iterable<String> ignorePackages) {
  var isRoot = rootName == pkg.name;

  var newLine = (escapeLabels) ? r'\n' : '\n';

  var label = pkg.name;
  if (pkg.version != null) {
    label = label + '$newLine${pkg.version}';
  }

  var props = {'label': label};

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
    props['style'] = 'bold';
  }

  if (!isRoot &&
      pkg.version != null &&
      pkg.latestVersion != null &&
      pkg.latestVersion.compareTo(pkg.version) > 0) {
    props['color'] = 'red';
    props['xlabel'] = '${pkg.latestVersion}';
  }

  gviz.addNode(pkg.name, properties: props);

  var orderedDeps = pkg.dependencies.toList(growable: false)..sort();

  for (var dep in orderedDeps.where((d) => !ignorePackages.contains(d.name))) {
    if (!dep.isDevDependency || isRoot) {
      var edgeProps = <String, String>{};

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

      if (dep.includesLatest != null && !dep.includesLatest) {
        edgeProps['fontcolor'] = 'red';
        if (edgeProps['color'] == 'gray') {
          edgeProps['color'] = 'pink';
        } else {
          edgeProps['color'] = 'red';
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

const _DOT_PLACE_HOLDER = 'DOT_HERE';

const _TITLE_PLACE_HOLDER = 'PACKAGE_TITLE';

const String _DOT_HTML_TEMPLATE = r'''
<!DOCTYPE html>
<html>
  <head>
    <title>pubviz - PACKAGE_TITLE</title>
    <base href="https://kevmoo.github.io/pubviz/">
    <link rel="stylesheet" href="style.css">
    <script src="viz-lite.js"></script>
  </head>
  <body>
    <button id="zoomBtn">Zoom</button>
    <script type="text/vnd.graphviz" id="dot">
DOT_HERE
    </script>
  </body>
  <script deferred src="web_app.dart.js"></script>
</html>
''';
