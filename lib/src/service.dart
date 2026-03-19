import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' hide Dependency;

import 'dependency.dart';
import 'deps_list.dart';
import 'outdated_info.dart';
import 'viz_package.dart';

abstract class Service {
  Map<String, Map<String, dynamic>>? _outdatedCache;

  String get rootPackageDir;

  Pubspec rootPubspec() {
    assert(
      Directory(rootPackageDir).existsSync(),
      '`$rootPackageDir` does not exist.',
    );

    final pubspecPath = p.join(rootPackageDir, 'pubspec.yaml');

    return Pubspec.parse(
      File(pubspecPath).readAsStringSync(),
      sourceUrl: Uri.parse(pubspecPath),
    );
  }

  DepsPackageEntry rootDeps();

  Iterable<DepsPackageEntry> allDeps();

  Future<Map<String, VizPackage>> getReferencedPackages(
    bool flagOutdated,
    bool directDependenciesOnly,
    bool productionDependenciesOnly, {
    bool includeWorkspace = false,
  }) async {
    final pubspec = rootPubspec();

    final map = SplayTreeMap<String, VizPackage>();

    final visitedTransitiveDeps = <String>{};

    void addPkg(VersionedEntry key, Map<String, VersionConstraint> value) {
      if (map.containsKey(key.name)) return;
      final pkg = VizPackage(
        key.name,
        key.version,
        SplayTreeSet.of(
          value.entries
              .where((element) => !_ignoredPackages.contains(element.key))
              .map(
                (entry) => Dependency(entry.key, entry.value.toString(), false),
              ),
        ),
        flagOutdated ? _latest(key.name) : null,
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

    final rootDepsEntry = rootDeps();

    if (includeWorkspace) {
      final memberPubspecs = <String, Pubspec>{
        pubspec.name: pubspec,
      };

      final workspace = pubspec.workspace;
      if (workspace != null && workspace.isNotEmpty) {
        for (final memberDir in workspace) {
          final memberPubspecPath =
              p.join(rootPackageDir, memberDir, 'pubspec.yaml');
          if (!File(memberPubspecPath).existsSync()) continue;
          final memberPubspec = Pubspec.parse(
            File(memberPubspecPath).readAsStringSync(),
            sourceUrl: Uri.file(memberPubspecPath),
          );
          memberPubspecs[memberPubspec.name] = memberPubspec;
        }
      }

      final workspaceMemberNames = memberPubspecs.keys.toSet();

      final workspacePackageEntries =
          allDeps().where((d) => workspaceMemberNames.contains(d.name));

      for (var entry in workspacePackageEntries) {
        final memberPubspec = memberPubspecs[entry.name]!;

        final dependencies = Dependency.getDependencies(
          memberPubspec,
          includeDevDependencies: !productionDependenciesOnly,
        ).where((d) => !_ignoredPackages.contains(d.name)).toSet();

        map[entry.name] = VizPackage(
          entry.name,
          entry.name == pubspec.name ? null : entry.version,
          SplayTreeSet.of(dependencies),
          flagOutdated ? _latest(entry.name) : null,
          isPrimary: true,
        );
        map[entry.name]!.onlyDev = false;

        visitedTransitiveDeps.addAll(
          dependencies
              .map((d) => d.name)
              .where((name) => !map.containsKey(name)),
        );
      }
    } else {

      map[pubspec.name] = VizPackage(
        pubspec.name,
        null,
        Dependency.getDependencies(
          pubspec,
          includeDevDependencies: !productionDependenciesOnly,
        ),
        null,
      );

      addSectionValues(rootDepsEntry.sections['dependencies'] ?? const {});

      if (!productionDependenciesOnly) {
        addSectionValues(
          rootDepsEntry.sections['dev dependencies'] ?? const {},
        );
      }
    }

    if (!directDependenciesOnly) {
      while (visitedTransitiveDeps.isNotEmpty) {
        final next = visitedTransitiveDeps.first;
        final removed = visitedTransitiveDeps.remove(next);
        assert(removed, 'it should be removed');
        final entry = rootDepsEntry.allEntries.entries.singleWhere(
          (element) => element.key.name == next,
          orElse: () =>
              throw StateError('Could not find an entry for `$next`.'),
        );

        addPkg(entry.key, entry.value);
      }
    }

    return map;
  }

  Version? _latest(String package) {
    _outdatedCache ??= {
      for (final map
          in (outdated()['packages'] as List).cast<Map<String, dynamic>>())
        if (map['package'] is String) map['package'] as String: map,
    };

    final map = _outdatedCache![package];
    if (map == null) {
      return null;
    }

    final info = OutdatedInfo.fromJson(map);
    return info.latest;
  }

  Map<String, dynamic> outdated();
}

const _ignoredPackages = {
  'sky_engine', // maps to `dart:ui` in Flutter – not useful
};
