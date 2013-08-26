library pubviz;

import 'dart:async';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as pathos;
import 'package:unmodifiable_collection/unmodifiable_collection.dart';

class VizRoot {
  final VizPackage root;
  final Map<String, VizPackage> packages;

  VizRoot._(this.root, Map<String, VizPackage> packages):
    this.packages = new UnmodifiableMapView(packages);

  static Future<VizRoot> forDirectory(String path) {
    return VizPackage.forDirectory(path)
        .then((VizPackage root) {

          return _getReferencedPackages(path)
              .then((packages) {
                assert(packages.containsKey(root.name));

                // want to make sure that the root note instance is the same
                // as the instance in the packages collection
                root = packages[root.name];

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

  static Future<Map<String, VizPackage>> _getReferencedPackages(String path) {
    var packs = new Map<String, VizPackage>();

    return _getPackageMap(path)
        .then((Map<String, String> map) {

          return Future.forEach(map.keys, (String packageName) {
            var subPath = map[packageName];
            return VizPackage.forDirectory(subPath)
                .then((VizPackage vp) {
                  assert(vp.name == packageName);

                  assert(!packs.containsKey(vp.name));
                  assert(!packs.containsValue(vp));
                  packs[vp.name] = vp;
                });
          });
        })
        .then((_) => packs);
  }



  String toDot() {
    _update();

    var sink = new StringBuffer();
    sink.writeln('digraph G {');
    sink.writeln('  node [fontname=Helvetica];');
    sink.writeln('  edge [fontname=Helvetica, fontcolor=gray];');

    var orderedPacks = packages.values.toList(growable: false)
        ..sort();

    for(var pack in orderedPacks) {
      sink.writeln();

      pack._write(sink, root.name);
    }

    sink.writeln('}');

    return sink.toString();
  }

  void _update() {
    if(root.isPrimary == false) {
      root.isPrimary = true;

      assert(root.onlyDev);
      root.onlyDev = false;

      for(var primaryDep in root.dependencies) {
        var package = packages[primaryDep.name];

        assert(!package.isPrimary);
        package.isPrimary = true;

        if(!primaryDep.isDevDependency) {
          _updateDevOnly(primaryDep);
        }
      }

    }
  }

  void _updateDevOnly(Dependency dep) {
    var package = packages[dep.name];

    if(package.onlyDev) {
      package.onlyDev = false;

      for(var subDep in package.dependencies.where((d) => !d.isDevDependency)) {
        _updateDevOnly(subDep);
      }
    }
  }
}

void _writeNode(StringSink sink, String name, Map<String, String> values) {
  sink.write('  $name');
  if(!values.isEmpty) {
    var props = values.keys.map((key) => '$key=${values[key]}')
        .toList(growable: false)
        .join(',');
    sink.write(' [$props]');
  }
  sink.writeln(';');
}

void _writeEdge(StringSink sink, String from, String to, Map<String, String> values) {
  var name = '$from -> $to';
  _writeNode(sink, name, values);
}

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

  VizPackage._(String path, this.name, this.version, Set<Dependency> deps) :
    dependencies = new UnmodifiableSetView(deps),
    this.path = pathos.normalize(path);

  static Future<VizPackage> forDirectory(String path) {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = pathos.join(path, 'pubspec.yaml');

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

  void _write(StringSink sink, String rootName) {
    var isRoot = rootName == name;

    var props =
      {
       'label' : '"$name\n$version"'
      };

    if(isRoot) {
      assert(!onlyDev);
      props['fontsize'] = '18';
      props['style'] = 'bold';
    }

    if(!onlyDev) {
      props['shape'] = 'box';
      props['margin'] = '"0.25,0.15"';
    }

    if(isPrimary) {
      props['style'] = 'bold';
    }

    _writeNode(sink, name, props);

    var orderedDeps = dependencies.toList(growable: false)
        ..sort();

    for(var dep in orderedDeps) {
      if(!dep.isDevDependency || isRoot) {
        var edgeProps = {};

        if(dep.versionConstraint != 'any') {
          edgeProps['label'] = '"${dep.versionConstraint}"';
        }

        if(isRoot) {
          edgeProps['penwidth'] = '2';
        }

        if(dep.isDevDependency) {
          edgeProps['style'] = 'dashed';
        } else if(onlyDev) {
          edgeProps['color'] = 'gray';
        }

        if(dep.name == rootName) {
          // If a package depends on the root node, it should not affect layout
          edgeProps['constraint'] = 'false';
        }

        _writeEdge(sink, name, dep.name, edgeProps);
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
