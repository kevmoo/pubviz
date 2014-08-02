library pubviz.viz_root;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:collection/wrappers.dart';

import 'dependency.dart';
import 'viz_package.dart';

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
                if(!packages.containsKey(root.name)) {
                  // the current package likely has no lib dir
                  var rootLibDirPath = pathos.join(path, 'lib');
                  var rootLibDir = new Directory(rootLibDirPath);
                  assert(!rootLibDir.existsSync());
                  packages[root.name] = root;
                }
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



  String toDot({bool escapeLabels: false}) {
    _update();

    var sink = new StringBuffer();
    sink.writeln('digraph G {');
    sink.writeln('  node [fontname=Helvetica];');
    sink.writeln('  edge [fontname=Helvetica, fontcolor=gray];');

    List<VizPackage> orderedPacks = packages.values.toList(growable: false)
        ..sort();

    for (var pack in orderedPacks) {
      sink.writeln();

      pack.write(sink, root.name, escapeLabels: escapeLabels);
    }

    sink.writeln('}');

    return sink.toString();
  }

  void _update() {
    if (root.isPrimary == false) {
      root.isPrimary = true;

      assert(root.onlyDev);
      root.onlyDev = false;

      for (var primaryDep in root.dependencies) {
        var package = packages[primaryDep.name];

        assert(!package.isPrimary);
        package.isPrimary = true;

        if (!primaryDep.isDevDependency) {
          _updateDevOnly(primaryDep);
        }
      }

    }
  }

  void _updateDevOnly(Dependency dep) {
    var package = packages[dep.name];

    if (package.onlyDev) {
      package.onlyDev = false;

      for(var subDep in package.dependencies.where((d) => !d.isDevDependency)) {
        _updateDevOnly(subDep);
      }
    }
  }
}
