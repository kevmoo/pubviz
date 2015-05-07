library pubviz.dot;

import 'viz_package.dart';
import 'viz_root.dart';

String toDot(VizRoot item,
    {bool escapeLabels: false, Iterable<String> ignorePackages}) {
  var sink = new StringBuffer();
  sink.writeln('digraph G {');
  sink.writeln('  node [fontname=Helvetica];');
  sink.writeln('  edge [fontname=Helvetica, fontcolor=gray];');

  for (var pack
      in item.packages.values.where((v) => !ignorePackages.contains(v.name))) {
    sink.writeln();
    _writeDot(pack, sink, item.root.name,
        escapeLabels: escapeLabels, ignorePackages: ignorePackages);
  }

  sink.writeln('}');

  return sink.toString();
}

void _writeDot(VizPackage pkg, StringSink sink, String rootName,
    {bool escapeLabels: false, Iterable<String> ignorePackages}) {
  var isRoot = rootName == pkg.name;

  var newLine = (escapeLabels) ? r'\n' : '\n';

  var label = pkg.name;
  if (pkg.version != null) {
    label = label + '$newLine$pkg.version';
  }

  var props = {'label': '"$label"'};

  if (isRoot) {
    assert(!pkg.onlyDev);
    props['fontsize'] = '18';
    props['style'] = 'bold';
  }

  if (!pkg.onlyDev) {
    props['shape'] = 'box';
    props['margin'] = '"0.25,0.15"';
  }

  if (pkg.isPrimary) {
    props['style'] = 'bold';
  }

  if (pkg.version != null &&
      pkg.latestVersion != null &&
      pkg.latestVersion.compareTo(pkg.version) > 0) {
    props['color'] = 'red';
    props['xlabel'] = '"$pkg.latestVersion"';
  }

  _writeNode(sink, '"$pkg.name"', props);

  var orderedDeps = pkg.dependencies.toList(growable: false)..sort();

  for (var dep in orderedDeps.where((d) => !ignorePackages.contains(d.name))) {
    if (!dep.isDevDependency || isRoot) {
      var edgeProps = {};

      if (!dep.versionConstraint.isAny) {
        edgeProps['label'] = '"${dep.versionConstraint}"';
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

      _writeEdge(sink, pkg.name, dep.name, edgeProps);
    }
  }
}

void _writeEdge(
    StringSink sink, String from, String to, Map<String, String> values) {
  var name = '"$from" -> "$to"';
  _writeNode(sink, name, values);
}

void _writeNode(StringSink sink, String name, Map<String, String> values) {
  sink.write('  $name');
  if (!values.isEmpty) {
    var props = values.keys
        .map((key) => '$key=${values[key]}')
        .toList(growable: false)
        .join(',');
    sink.write(' [$props]');
  }
  sink.writeln(';');
}
