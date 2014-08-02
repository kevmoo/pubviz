library pubviz.viz_package;

import 'dart:async';
import 'dart:io';
import 'package:collection/wrappers.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

import 'dependency.dart';

class VizPackage extends Comparable {
  final String path;
  final String name;
  final String version;
  final Set<Dependency> dependencies;
  bool isPrimary = false;

  bool _onlyDev = true;

  bool get onlyDev => _onlyDev;

  void set onlyDev(bool value) {
    assert(value == false);
    assert(_onlyDev == true);

    _onlyDev = value;
  }

  VizPackage._(String path, this.name, this.version, Set<Dependency> deps)
      : dependencies = new UnmodifiableSetView(deps),
        this.path = p.normalize(path);

  static Future<VizPackage> forDirectory(String path) {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = p.join(path, 'pubspec.yaml');

    Map<String, dynamic> pubspecMap;

    return openYaml(pubspecPath)
        .then((Map value) {
          pubspecMap = value;

          String packageName = pubspecMap['name'];
          assert(packageName != null && packageName.length > 0);

          String version = pubspecMap['version'];
          if(version == null) version = '';

          var deps = Dependency.getDependencies(pubspecMap);

          return new VizPackage._(path, packageName, version, deps);
        });
  }

  String toString() => '$name @ $path';

  int compareTo(VizPackage other) {
    return name.compareTo(other.name);
  }

  bool operator ==(other) {
    if (other is VizPackage) {
      var match = (name == other.name);
      if (match) {
        assert(other.path == path);
        assert(other.version == version);
        return true;
      }
    }
    return false;
  }

  int get hashCode => name.hashCode;

  void write(StringSink sink, String rootName, {bool escapeLabels: false}) {
    var isRoot = rootName == name;

    var newLine = (escapeLabels) ? r'\n' : '\n';

    var label = name;
    if (version.isNotEmpty) {
      label = label + '$newLine$version';
    }

    var props = { 'label' : '"$label"' };

    if (isRoot) {
      assert(!onlyDev);
      props['fontsize'] = '18';
      props['style'] = 'bold';
    }

    if (!onlyDev) {
      props['shape'] = 'box';
      props['margin'] = '"0.25,0.15"';
    }

    if (isPrimary) {
      props['style'] = 'bold';
    }

    writeNode(sink, name, props);

    var orderedDeps = dependencies.toList(growable: false)
        ..sort();

    for (var dep in orderedDeps) {
      if (!dep.isDevDependency || isRoot) {
        var edgeProps = {};

        if (dep.versionConstraint != 'any') {
          edgeProps['label'] = '"${dep.versionConstraint}"';
        }

        if (isRoot) {
          edgeProps['penwidth'] = '2';
        }

        if (dep.isDevDependency) {
          edgeProps['style'] = 'dashed';
        } else if (onlyDev) {
          edgeProps['color'] = 'gray';
        }

        if (dep.name == rootName) {
          // If a package depends on the root node, it should not affect layout
          edgeProps['constraint'] = 'false';
        }

        writeEdge(sink, name, dep.name, edgeProps);
      }
    }
  }
}

void writeNode(StringSink sink, String name, Map<String, String> values) {
  sink.write('  $name');
  if(!values.isEmpty) {
    var props = values.keys.map((key) => '$key=${values[key]}')
        .toList(growable: false)
        .join(',');
    sink.write(' [$props]');
  }
  sink.writeln(';');
}

void writeEdge(StringSink sink, String from, String to, Map<String, String> values) {
  var name = '$from -> $to';
  writeNode(sink, name, values);
}

Future<Map<String, dynamic>> openYaml(String path) {
  var file = new File(path);
  return file.readAsString().then(yaml.loadYaml);
}
