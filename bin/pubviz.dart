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

  VizRoot.forDirectory(path)
    .then((VizRoot vp) {
      print(vp.toDot());
    });
}

class VizRoot {
  final VizPackage root;
  final Set<VizPackage> packages;

  VizRoot._(this.root, Set<VizPackage> packages):
    this.packages = new UnmodifiableSetView(packages);

  static Future<VizRoot> forDirectory(String path) {
    return VizPackage.forDirectory(path)
        .then((VizPackage root) {

          return _getReferencedPackages(path)
              .then((packages) {
                assert(packages.contains(root));

                return new VizRoot._(root, packages);
              });
        });
  }


  static Future<Map<String, String>> _getPackageMap(String path) {
    var packagePath = pathos.join(path, 'packages');
    var packageDir = new Directory(packagePath);

    var dirs = new Map<String, String>();

    var map = new Map<String, String>();

    return packageDir.list(recursive: false, followLinks: false)
        .toList()
        .then((List<Link> links) {
          return Future.forEach(links, (link) {
            return link.target()
                .then((String targetPath) {
                  var linkName = pathos.basename(link.path);

                  if(pathos.isRelative(targetPath)) {
                    targetPath = pathos.join(packagePath, targetPath);
                    targetPath = pathos.normalize(targetPath);
                  }

                  assert(pathos.isAbsolute(targetPath));
                  assert(pathos.basename(targetPath) == 'lib');

                  targetPath = pathos.dirname(targetPath);

                  assert(!map.containsKey(linkName));
                  assert(!map.containsValue(targetPath));

                  map[linkName] = targetPath;
                });
          });
        })
        .then((_) => map);
  }

  static Future<Set<VizPackage>> _getReferencedPackages(String path) {
    var set = new Set<VizPackage>();

    return _getPackageMap(path)
        .then((Map<String, String> map) {

          return Future.forEach(map.keys, (String packageName) {
            var subPath = map[packageName];
            return VizPackage.forDirectory(subPath)
                .then((VizPackage vp) {
                  assert(vp.name == packageName);

                  assert(!set.contains(vp));
                  set.add(vp);
                });
          });
        })
        .then((_) => set);
  }



  String toDot() {
    var sink = new StringBuffer();
    sink.writeln('digraph G {');


    var orderedPacks = packages.toList(growable: false)
        ..sort();

    for(var pack in orderedPacks) {
      sink.writeln('  ${pack.name} [label="${pack.name}\n${pack.version}",shape=box]');

      pack._writeConnections(sink, root == pack);
    }

    sink.writeln('}');

    return sink.toString();
  }

  void _writeNodes(StringSink sink) {
  }
}

class VizPackage extends Comparable {
  final String path;
  final String name;
  final String version;
  final Set<Dependency> dependencies;

  VizPackage._(String path, this.name, this.version, Set<Dependency> deps) :
    dependencies = new UnmodifiableSetView(deps),
    this.path = pathos.normalize(path);

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
    if(other is VizPackage) {
      var match = (name == other.name);
      if(match) {
        assert(other.path == path);
        assert(other.version == version);
        return true;
      }
    }
    return false;
  }

  int get hashCode => name.hashCode;

  void _writeConnections(StringSink sink, bool includeDevDependencies) {
    var orderedDeps = dependencies.toList(growable: false)
        ..sort();

    for(var dep in orderedDeps) {
      if(!dep.isDevDependency || includeDevDependencies) {
        sink.write('  $name -> ${dep.name} [label="${dep.versionConstraint}", fontcolor=gray');
        if(dep.isDevDependency) {
          sink.write(',style=dotted');
        }
        sink.writeln(']');
      }
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
