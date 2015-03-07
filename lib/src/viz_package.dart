library pubviz.viz_package;

import 'dart:async';
import 'dart:io';
import 'package:collection/wrappers.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'dependency.dart';
import 'util.dart';

class VizPackage extends Comparable {
  final String path;
  final String name;
  final Version version;
  final Set<Dependency> dependencies;
  bool isPrimary = false;

  bool _onlyDev = true;

  bool get onlyDev => _onlyDev;

  void set onlyDev(bool value) {
    assert(value == false);
    assert(_onlyDev == true);

    _onlyDev = value;
  }

  Version _latestVersion;

  Version get latestVersion => _latestVersion;

  VizPackage._(String path, this.name, this.version, Set<Dependency> deps)
      : dependencies = new UnmodifiableSetView(deps),
        this.path = p.normalize(path);

  static Future<VizPackage> forDirectory(String path,
      {bool flagOutdated: false}) async {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = p.join(path, 'pubspec.yaml');

    Map<String, dynamic> pubspecMap = await _openYaml(pubspecPath);

    String packageName = pubspecMap['name'];
    assert(packageName != null && packageName.length > 0);

    var versionString = pubspecMap['version'];
    var version =
        (versionString == null) ? null : new Version.parse(versionString);

    var deps = Dependency.getDependencies(pubspecMap);

    var package = new VizPackage._(path, packageName, version, deps);

    if (flagOutdated) {
      await package.updateLatestVersion();
    }

    return package;
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
    if (version != null) {
      label = label + '$newLine$version';
    }

    var props = {'label': '"$label"'};

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

    if (version != null &&
        latestVersion != null &&
        latestVersion.compareTo(version) > 0) {
      props['color'] = 'red';
      props['xlabel'] = '"$latestVersion"';
    }

    _writeNode(sink, name, props);

    var orderedDeps = dependencies.toList(growable: false)..sort();

    for (var dep in orderedDeps) {
      if (!dep.isDevDependency || isRoot) {
        var edgeProps = {};

        if (!dep.versionConstraint.isAny) {
          edgeProps['label'] = '"${dep.versionConstraint}"';
        }

        if (dep.includesLatest != null && !dep.includesLatest) {
          edgeProps['fontcolor'] = 'red';
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

        _writeEdge(sink, name, dep.name, edgeProps);
      }
    }
  }

  Future<Version> updateLatestVersion() async {
    if (_latestVersion != null) return _latestVersion;

    _latestVersion = await getLatestVersion(name);

    return _latestVersion;
  }
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

void _writeEdge(
    StringSink sink, String from, String to, Map<String, String> values) {
  var name = '$from -> $to';
  _writeNode(sink, name, values);
}

Future<Map<String, dynamic>> _openYaml(String path) async {
  var file = new File(path);
  var value = await file.readAsString();
  return yaml.loadYaml(value);
}
