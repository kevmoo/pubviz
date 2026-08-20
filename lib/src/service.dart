import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as parse;

import 'dependency.dart';
import 'outdated_info.dart';
import 'viz_package.dart';

/// Abstract service providing package dependency graph and metadata resolution.
abstract class Service {
  Map<String, Map<String, dynamic>>? _outdatedCache;

  /// The root directory of the package or workspace to analyze.
  String get rootPackageDir;

  /// Reads and parses the `pubspec.yaml` file located in [rootPackageDir].
  ///
  /// Throws [FileSystemException] if [rootPackageDir] does not exist or does
  /// not contain a valid `pubspec.yaml`.
  parse.Pubspec rootPubspec() {
    final dir = Directory(rootPackageDir);
    if (!dir.existsSync()) {
      throw FileSystemException(
        '`$rootPackageDir` does not exist.',
        rootPackageDir,
      );
    }

    final pubspecPath = p.join(rootPackageDir, 'pubspec.yaml');
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      throw FileSystemException(
        'Could not find `pubspec.yaml` in `$rootPackageDir`.',
        pubspecPath,
      );
    }

    return parse.Pubspec.parse(
      file.readAsStringSync(),
      sourceUrl: Uri.file(pubspecPath),
    );
  }

  /// Locates a file named [fileName] inside a `.dart_tool` directory,
  /// searching [rootPackageDir] and ascending parent directories.
  ///
  /// Throws [FileSystemException] if `.dart_tool/[fileName]` cannot be found.
  File _findDartToolFile(String fileName) {
    var dir = Directory(rootPackageDir).absolute;
    while (true) {
      final candidate = File(p.join(dir.path, '.dart_tool', fileName));
      if (candidate.existsSync()) {
        return candidate;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    throw FileSystemException(
      'Could not find `.dart_tool/$fileName` in "$rootPackageDir" or any of '
      'its parent directories. Run `dart pub get` first.',
    );
  }

  /// Loads and parses the `.dart_tool/package_graph.json` file.
  _PackageGraphFile _loadPackageGraphFile() {
    final file = _findDartToolFile('package_graph.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _PackageGraphFile.fromJson(json);
  }

  /// Loads and parses the `.dart_tool/package_config.json` file.
  _PackageConfigFile _loadPackageConfigFile() {
    final file = _findDartToolFile('package_config.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final baseUri = Uri.directory(file.parent.path);
    return _PackageConfigFile.fromJson(json, baseUri: baseUri);
  }

  /// Loads the [parse.Pubspec] for package [packageName] using the locations in
  /// [config].
  parse.Pubspec? _loadPubspecForPackage(
    String packageName,
    _PackageConfigFile config,
  ) {
    final entry = config.packages[packageName];
    if (entry == null) return null;
    if (entry.rootUri.scheme != 'file') return null;
    final pubspecFile = File(
      p.join(entry.rootUri.toFilePath(), 'pubspec.yaml'),
    );
    if (!pubspecFile.existsSync()) return null;
    try {
      return parse.Pubspec.parse(
        pubspecFile.readAsStringSync(),
        sourceUrl: pubspecFile.uri,
      );
    } catch (_) {
      return null;
    }
  }

  /// Resolves the version constraint for [depName] declared in [pubspec].
  VersionConstraint _getConstraint(
    parse.Pubspec? pubspec,
    String depName, {
    required bool isDev,
  }) {
    if (pubspec == null) return VersionConstraint.empty;
    if (isDev) {
      if (pubspec.devDependencies.containsKey(depName)) {
        return _extractConstraint(pubspec.devDependencies[depName]!);
      }
    } else {
      if (pubspec.dependencies.containsKey(depName)) {
        return _extractConstraint(pubspec.dependencies[depName]!);
      }
      if (pubspec.dependencyOverrides.containsKey(depName)) {
        return _extractConstraint(pubspec.dependencyOverrides[depName]!);
      }
    }
    return VersionConstraint.empty;
  }

  static VersionConstraint _extractConstraint(parse.Dependency dep) {
    if (dep is parse.HostedDependency) {
      return dep.version;
    }
    final str = dep.toString();
    try {
      return VersionConstraint.parse(str);
    } on FormatException {
      return VersionConstraint.empty;
    }
  }

  /// Resolves all referenced package nodes from `.dart_tool/package_graph.json`
  /// and `.dart_tool/package_config.json`.
  ///
  /// When [includeWorkspace] is `true`, all workspace members defined as roots
  /// in `package_graph.json` are treated as primary package nodes.
  ///
  /// Throws [FileSystemException] if the required `.dart_tool` files are
  /// missing.
  /// Throws [StateError] if a referenced dependency is missing from
  /// `package_graph.json`.
  Future<Map<String, VizPackage>> getReferencedPackages(
    bool flagOutdated,
    bool directDependenciesOnly,
    bool productionDependenciesOnly, {
    bool includeWorkspace = false,
  }) async {
    final pubspec = rootPubspec();
    final graphFile = _loadPackageGraphFile();
    final configFile = _loadPackageConfigFile();

    final map = SplayTreeMap<String, VizPackage>();
    final visitedTransitiveDeps = <String>{};

    final pubspecCache = <String, parse.Pubspec?>{};
    parse.Pubspec? getPubspec(String name) => pubspecCache.putIfAbsent(
      name,
      () => _loadPubspecForPackage(name, configFile),
    );

    // Ensure root pubspec is cached
    pubspecCache[pubspec.name] = pubspec;

    void addPkg(String name) {
      if (map.containsKey(name)) return;

      final graphEntry = graphFile.packages[name];
      if (graphEntry == null) {
        throw StateError('Could not find an entry for `$name`.');
      }

      final pkgPubspec = getPubspec(name);
      final dependencies = <Dependency>{};

      for (final depName in graphEntry.dependencies) {
        if (_ignoredPackages.contains(depName)) continue;
        dependencies.add(
          Dependency(
            depName,
            _getConstraint(pkgPubspec, depName, isDev: false),
            false,
          ),
        );
      }

      final isPublishToNone = pkgPubspec?.publishTo == 'none';

      map[name] = VizPackage(
        name,
        graphEntry.version ?? pkgPubspec?.version,
        SplayTreeSet.of(dependencies),
        flagOutdated ? _latest(name) : null,
        isPublishToNone: isPublishToNone,
      );

      if (!directDependenciesOnly) {
        visitedTransitiveDeps.addAll(
          dependencies
              .map((d) => d.name)
              .where((depName) => !map.containsKey(depName)),
        );
      }
    }

    final primaryRoots = includeWorkspace && graphFile.roots.isNotEmpty
        ? graphFile.roots.toSet()
        : {pubspec.name};

    for (final rootName in primaryRoots) {
      final graphEntry = graphFile.packages[rootName];
      final memberPubspec =
          getPubspec(rootName) ?? (rootName == pubspec.name ? pubspec : null);

      final dependencies = <Dependency>{};

      // Production dependencies
      final prodDepNames =
          graphEntry?.dependencies ??
          memberPubspec?.dependencies.keys ??
          const <String>[];
      for (final depName in prodDepNames) {
        if (_ignoredPackages.contains(depName)) continue;
        dependencies.add(
          Dependency(
            depName,
            _getConstraint(memberPubspec, depName, isDev: false),
            false,
          ),
        );
      }

      // Dev dependencies
      if (!productionDependenciesOnly) {
        final devDepNames =
            graphEntry?.devDependencies ??
            memberPubspec?.devDependencies.keys ??
            const <String>[];
        for (final depName in devDepNames) {
          if (_ignoredPackages.contains(depName)) continue;
          dependencies.add(
            Dependency(
              depName,
              _getConstraint(memberPubspec, depName, isDev: true),
              true,
            ),
          );
        }
      }

      final isPublishToNone = memberPubspec?.publishTo == 'none';
      final version = includeWorkspace
          ? (rootName == pubspec.name || isPublishToNone
                ? null
                : (graphEntry?.version ?? memberPubspec?.version))
          : memberPubspec?.version;

      map[rootName] = VizPackage(
        rootName,
        version,
        SplayTreeSet.of(dependencies),
        includeWorkspace && flagOutdated ? _latest(rootName) : null,
        isPrimary: true,
        onlyDev: false,
        isPublishToNone: isPublishToNone,
      );

      for (final dep in dependencies) {
        addPkg(dep.name);
      }
    }

    // Resolve transitive dependencies
    if (!directDependenciesOnly) {
      while (visitedTransitiveDeps.isNotEmpty) {
        final next = visitedTransitiveDeps.first;
        visitedTransitiveDeps.remove(next);
        addPkg(next);
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

  /// Returns the JSON representation of package outdated information.
  Map<String, dynamic> outdated();
}

const _ignoredPackages = {
  'sky_engine', // maps to `dart:ui` in Flutter – not useful
};

final class _PackageGraphFile {
  final List<String> roots;
  final Map<String, _PackageGraphPackage> packages;

  _PackageGraphFile({required this.roots, required this.packages});

  factory _PackageGraphFile.fromJson(Map<String, dynamic> json) {
    final roots = (json['roots'] as List? ?? const <dynamic>[]).cast<String>();
    final packagesList = (json['packages'] as List? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    final packagesMap = <String, _PackageGraphPackage>{};
    for (final pkgJson in packagesList) {
      final pkg = _PackageGraphPackage.fromJson(pkgJson);
      packagesMap[pkg.name] = pkg;
    }

    return _PackageGraphFile(roots: roots, packages: packagesMap);
  }
}

final class _PackageGraphPackage {
  final String name;
  final Version? version;
  final List<String> dependencies;
  final List<String> devDependencies;
  final List<String> dependencyOverrides;

  _PackageGraphPackage({
    required this.name,
    this.version,
    required this.dependencies,
    required this.devDependencies,
    required this.dependencyOverrides,
  });

  factory _PackageGraphPackage.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final versionStr = json['version'] as String?;
    Version? version;
    if (versionStr != null) {
      try {
        version = Version.parse(versionStr);
      } catch (_) {}
    }

    final dependencies = (json['dependencies'] as List? ?? const <dynamic>[])
        .cast<String>();
    final devDependencies =
        (json['devDependencies'] as List? ?? const <dynamic>[]).cast<String>();
    final dependencyOverrides =
        (json['dependencyOverrides'] as List? ?? const <dynamic>[])
            .cast<String>();

    return _PackageGraphPackage(
      name: name,
      version: version,
      dependencies: dependencies,
      devDependencies: devDependencies,
      dependencyOverrides: dependencyOverrides,
    );
  }
}

final class _PackageConfigFile {
  final Map<String, _PackageConfigEntry> packages;

  _PackageConfigFile({required this.packages});

  factory _PackageConfigFile.fromJson(
    Map<String, dynamic> json, {
    required Uri baseUri,
  }) {
    final packagesList = (json['packages'] as List? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();
    final map = <String, _PackageConfigEntry>{};
    for (final pkgJson in packagesList) {
      final entry = _PackageConfigEntry.fromJson(pkgJson, baseUri: baseUri);
      map[entry.name] = entry;
    }
    return _PackageConfigFile(packages: map);
  }
}

final class _PackageConfigEntry {
  final String name;
  final Uri rootUri;
  final Uri? packageUri;

  _PackageConfigEntry({
    required this.name,
    required this.rootUri,
    this.packageUri,
  });

  factory _PackageConfigEntry.fromJson(
    Map<String, dynamic> json, {
    required Uri baseUri,
  }) {
    final name = json['name'] as String;
    final rawRootUri = json['rootUri'] as String;
    final resolvedRoot = baseUri.resolve(rawRootUri);
    final rawPackageUri = json['packageUri'] as String?;
    final resolvedPackageUri = rawPackageUri != null
        ? resolvedRoot.resolve(rawPackageUri)
        : null;

    return _PackageConfigEntry(
      name: name,
      rootUri: resolvedRoot,
      packageUri: resolvedPackageUri,
    );
  }
}
