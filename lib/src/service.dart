import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' hide Dependency;

import 'dependency.dart';
import 'deps_list.dart';
import 'viz_package.dart';

abstract class Service {
  Map<String, dynamic> _outdatedCache;

  String get rootPackageDir;

  Pubspec rootPubspec() {
    assert(Directory(rootPackageDir).existsSync(),
        '`$rootPackageDir` does not exist.');

    final pubspecPath = p.join(rootPackageDir, 'pubspec.yaml');

    return Pubspec.parse(
      File(pubspecPath).readAsStringSync(),
      sourceUrl: pubspecPath,
    );
  }

  DepsList rootDeps();

  Future<Map<String, VizPackage>> getReferencedPackages(
    bool flagOutdated,
    bool directDependencies,
  ) async {
    final pubspec = rootPubspec();

    final map = SplayTreeMap<String, VizPackage>();

    map[pubspec.name] = VizPackage(
      pubspec.name,
      null,
      Dependency.getDependencies(pubspec),
      null,
    );

    final visitedTransitiveDeps = <String>{};

    void addPkg(VersionedEntry key, Map<String, VersionConstraint> value) {
      final pkg = VizPackage(
        key.name,
        key.version,
        SplayTreeSet.of(
          value.entries.map(
            (entry) => Dependency(entry.key, entry.value.toString(), false),
          ),
        ),
        flagOutdated ? latest(key.name) : null,
      );
      map[pkg.name] = pkg;

      visitedTransitiveDeps.addAll(
        pkg.dependencies
            .map((e) => e.name)
            .where((element) => !map.containsKey(element)),
      );
    }

    void addSectionValues(
      Map<VersionedEntry, Map<String, VersionConstraint>> section,
    ) {
      for (var entry in section.entries) {
        addPkg(entry.key, entry.value);
      }
    }

    final deps = rootDeps();

    addSectionValues(deps.sections['dependencies'] ?? const {});

    if (!directDependencies) {
      addSectionValues(deps.sections['dev dependencies'] ?? const {});

      while (visitedTransitiveDeps.isNotEmpty) {
        final next = visitedTransitiveDeps.first;
        final removed = visitedTransitiveDeps.remove(next);
        assert(removed, 'it should be removed');
        final entry = deps.allEntries.entries
            .singleWhere((element) => element.key.name == next);

        addPkg(entry.key, entry.value);
      }
    }

    return map;
  }

  Version latest(String package) {
    final list = (_outdatedCache ??= outdated())['packages'] as List;
    final map = list.cast<Map<String, dynamic>>().singleWhere(
        (element) => element['package'] == package,
        orElse: () => null);

    if (map == null) {
      return null;
    }

    final info = OutdatedInfo.fromJson(map);
    return info.latest;
  }

  Map<String, dynamic> outdated();
}

class OutdatedInfo {
  final String package;
  final Version current, upgradable, resolvable, latest;

  OutdatedInfo(
    this.package,
    this.current,
    this.upgradable,
    this.resolvable,
    this.latest,
  );

  factory OutdatedInfo.fromJson(Map<String, dynamic> json) => OutdatedInfo(
        json['package'] as String,
        _version(json, 'current'),
        _version(json, 'upgradable'),
        _version(json, 'resolvable'),
        _version(json, 'latest'),
      );
}

Version _version(Map<String, dynamic> json, String key) => Version.parse(
      (json[key] as Map<String, dynamic>)['version'] as String,
    );
