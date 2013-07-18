import 'dart:async';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as pathos;
import 'dart:json' as json;
import 'package:unmodifiable_collection/unmodifiable_collection.dart';

const _pubspecFile = 'pubspec.yaml';

void main() {
  var args = (new Options()).arguments;

  if(args.length != 1) {
    print("should only have one arg -> a path");
    exit(1);
    return;
  }

  final path = args[0];

  VizPackage.forDirectory(path)
    .then((VizPackage vp) {
      print(vp.toDot());
    });
}

class VizPackage {
  final String path;
  final String name;
  final Set<Dependency> dependencies;

  VizPackage._(this.path, this.name, Set<Dependency> deps) :
    dependencies = new UnmodifiableSetView(deps);

  static Future<VizPackage> forDirectory(String path) {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = pathos.join(path, _pubspecFile);

    Map<String, dynamic> pubspecMap;

    return _openYaml(pubspecPath)
        .then((Map value) {
          pubspecMap = value;

          String packageName = pubspecMap['name'];
          assert(packageName != null && packageName.length > 0);

          var deps = Dependency.getDependencies(pubspecMap);

          return new VizPackage._(path, packageName, deps);
        });
  }

  String toString() => '$name @ $path';

  String toDot() {
    var sink = new StringBuffer();
    sink.writeln('digraph G {');
    _writeConnections(sink);
    sink.writeln('}');

    return sink.toString();
  }

  void _writeConnections(StringSink sink) {
    var orderedDeps = dependencies.toList(growable: false)
        ..sort();

    for(var dep in orderedDeps) {
      sink.write('  $name -> ${dep.name}');
      if(dep.isDevDependency) {
        sink.write(' [style=dotted]');
      }
      sink.writeln();
    }
  }
}

class Dependency implements Comparable<Dependency> {
  final String name;
  final String versionConstraint;
  final bool isDevDependency;

  Dependency._(this.name, this.versionConstraint, this.isDevDependency);

  static Set<Dependency> getDependencies(Map<String, dynamic> yaml) {
    var deps = new Set<Dependency>();

    _populateFromSection(yaml['dependencies'],deps, false);
    _populateFromSection(yaml['dev_dependencies'],deps, true);

    return deps;
  }

  static void _populateFromSection(Map<String, dynamic> yaml, Set<Dependency> value, bool isDev) {
    if(yaml != null) {
      yaml.forEach((String key, constraint) {
        if(constraint == null) {
          constraint = '';
        } else if(constraint is Map) {
          constraint = '??complex??';
        }

        var dep = new Dependency._(key, constraint, isDev);
        assert(!value.contains(dep));

        value.add(dep);
      });
    }
  }

  bool operator==(other) => other is Dependency && other.name == name;

  int get hashcode => name.hashCode;

  int compareTo(Dependency other) {
    if(other.isDevDependency == isDevDependency) {
      return name.compareTo(other.name);
    } else if(isDevDependency) {
      return 1;
    } else {
      return -1;
    }
  }

  String toString() {
    var devStr = isDevDependency ? '(dev)' : '';
    return '$name$devStr $versionConstraint';
  }
}

Future<Map<String, dynamic>> _openYaml(String path) {
  var file = new File(path);
  return file.readAsString()
      .then(loadYaml);
}
