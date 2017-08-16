import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'dependency.dart';
import 'viz_package.dart';

class VizRoot {
  final VizPackage root;
  final Map<String, VizPackage> packages;
  final bool flagOutdated;

  VizRoot._(this.root, Map<String, VizPackage> packages, this.flagOutdated)
      : this.packages = new UnmodifiableMapView(packages);

  static Future<VizRoot> forDirectory(String path,
      {bool flagOutdated: false, Iterable<String> ignorePackages}) async {
    var root = await VizPackage.forDirectory(path);
    var packages = await _getReferencedPackages(path, flagOutdated);

    // want to make sure that the root node instance is the same
    // as the instance in the packages collection
    root = packages[root.name];
    assert(root != null);

    var value = new VizRoot._(root, packages, flagOutdated);

    if (flagOutdated) {
      for (var dep in _allDeps(value, ignorePackages)) {
        assert(dep.includesLatest == null);

        var package = packages[dep.name];

        if (package != null &&
            package.latestVersion != null &&
            dep.versionConstraint != VersionConstraint.empty) {
          var allowsLatest =
              dep.versionConstraint.allows(package.latestVersion);

          if (!allowsLatest) {
            // it could be that the versionConstraint is actually *ahead* of
            // latest – with a pre-release version

            if (package.latestVersion.compareTo(dep.versionConstraint) < 0) {
              allowsLatest = true;
            }
          }

          dep.includesLatest = allowsLatest;
        }
      }
    }

    value._update();

    return value;
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

      for (var subDep
          in package.dependencies.where((d) => !d.isDevDependency)) {
        _updateDevOnly(subDep);
      }
    }
  }
}

Future<Map<String, String>> _getPackageMap(String path) async {
  var map = new Map<String, String>();

  var result = await Process.run('pub', ['list-package-dirs'],
      runInShell: true, workingDirectory: path);

  if (result.exitCode != 0) {
    throw new ProcessException(
        'pub', ['list-package-dirs'], result.stderr, result.exitCode);
  }

  var json = JSON.decode(result.stdout as String);

  var packages = json['packages'] as Map;

  packages.forEach((k, v) {
    assert(p.basename(v) == 'lib');
    map[k] = p.dirname(v);
  });

  return map;
}

Future<Map<String, VizPackage>> _getReferencedPackages(
    String path, bool flagOutdated) async {
  var packs = new SplayTreeMap<String, VizPackage>();

  var map = await _getPackageMap(path);

  var futures = map.keys.map((packageName) async {
    var subPath = map[packageName];
    var vp = await VizPackage.forDirectory(subPath, flagOutdated: flagOutdated);
    assert(vp.name == packageName);

    assert(!packs.containsKey(vp.name));
    assert(!packs.containsValue(vp));
    packs[vp.name] = vp;
  });

  await Future.wait(futures);

  return packs;
}

Iterable<Dependency> _allDeps(
    VizRoot root, Iterable<String> ignorePackages) sync* {
  for (var pkg
      in root.packages.values.where((v) => !ignorePackages.contains(v))) {
    yield* pkg.dependencies;
  }
}
