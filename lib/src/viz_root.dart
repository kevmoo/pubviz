import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'dependency.dart';
import 'viz_package.dart';

class VizRoot {
  final VizPackage root;
  final Map<String, VizPackage> packages;

  VizRoot._(this.root, Map<String, VizPackage> packages)
      : packages = UnmodifiableMapView(packages);

  static Future<VizRoot> forDirectory(
    String path, {
    bool flagOutdated = false,
    Iterable<String> ignorePackages,
    bool directDependencies = false,
  }) async {
    var root = await VizPackage.forDirectory(path);
    final packages =
        await _getReferencedPackages(path, flagOutdated, directDependencies);

    // want to make sure that the root node instance is the same
    // as the instance in the packages collection
    root = packages[root.name];
    assert(root != null);

    final value = VizRoot._(root, packages);

    if (flagOutdated) {
      for (var dep in _allDeps(value, ignorePackages)) {
        assert(dep.includesLatest == null);

        final package = packages[dep.name];

        if (package != null &&
            package.latestVersion != null &&
            dep.versionConstraint != VersionConstraint.empty) {
          var allowsLatest =
              dep.versionConstraint.allows(package.latestVersion);

          if (!allowsLatest) {
            // it could be that the versionConstraint is actually *ahead* of
            // latest – with a pre-release version

            // TODO: get rid of the `as` here – this is weird!
            final constraintAsRange = dep.versionConstraint as VersionRange;
            if (package.latestVersion.compareTo(constraintAsRange) < 0) {
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
        final package = packages[primaryDep.name];
        if (package == null) continue;

        assert(!package.isPrimary);
        package.isPrimary = true;

        if (!primaryDep.isDevDependency) {
          _updateDevOnly(primaryDep);
        }
      }
    }
  }

  void _updateDevOnly(Dependency dep) {
    final package = packages[dep.name];

    if (package?.onlyDev == true) {
      package.onlyDev = false;

      package?.dependencies
          ?.where((d) => !d.isDevDependency)
          ?.forEach(_updateDevOnly);
    }
  }
}

Map<String, String> _getPackageMap(
  String path,
  bool withFlutter,
  bool directDependencies,
) {
  final map = <String, String>{};

  final proc = withFlutter ? 'flutter' : 'pub';
  final args = withFlutter
      ? ['packages', 'pub', 'list-package-dirs']
      : ['list-package-dirs'];

  final result = Process.runSync(
    proc,
    args,
    runInShell: true,
    workingDirectory: path,
  );

  if (result.exitCode != 0) {
    var message = result.stderr as String;
    try {
      final value = jsonDecode(result.stdout as String) as Map;
      if (value.containsKey('error')) {
        message = value['error'] as String;
      }
    } catch (e) {
      // NOOP
    }

    throw ProcessException(
      'pub',
      ['list-package-dirs'],
      message,
      result.exitCode,
    );
  }

  final json = jsonDecode(result.stdout as String);
  var packageEntries = (json['packages'] as Map<String, dynamic>).entries;

  if (directDependencies) {
    final yaml = loadYaml(File('$path/pubspec.yaml').readAsStringSync());
    final directDependencies = yaml['dependencies'].value.keys as Iterable;
    packageEntries = packageEntries.where(
      (entry) =>
          directDependencies.contains(entry.key) || entry.key == yaml['name'],
    );
  }

  for (var entry in packageEntries) {
    assert(p.basename(entry.value as String) == 'lib');
    map[entry.key] = p.dirname(entry.value as String);
  }

  return map;
}

Future<Map<String, VizPackage>> _getReferencedPackages(
  String path,
  bool flagOutdated,
  bool directDependencies,
) async {
  final packs = SplayTreeMap<String, VizPackage>();

  Map<String, String> map;
  try {
    map = _getPackageMap(path, false, directDependencies);
  } on ProcessException catch (e) {
    if (e.message.startsWith('Flutter is not available.') ||
        e.message.startsWith('The Flutter SDK is not available.')) {
      map = _getPackageMap(path, true, directDependencies);
    } else {
      rethrow;
    }
  }

  // TODO(kevmoo): consider a pool here!
  final futures = map.keys.map((packageName) async {
    final subPath = map[packageName];
    final vp =
        await VizPackage.forDirectory(subPath, flagOutdated: flagOutdated);
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
      in root.packages.values.where((v) => !ignorePackages.contains(v.name))) {
    yield* pkg.dependencies;
  }
}
