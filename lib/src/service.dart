import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
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

  /// Locates a file named [fileName] inside a `.dart_tool` directory.
  ///
  /// When [ascend] is `true`, searches [rootPackageDir] and ascending parent
  /// directories. Otherwise, only checks [rootPackageDir].
  ///
  /// Throws [FileSystemException] if `.dart_tool/[fileName]` cannot be found.
  File _findDartToolFile(String fileName, {required bool ascend}) {
    var dir = Directory(rootPackageDir).absolute;
    while (true) {
      final candidate = File(p.join(dir.path, '.dart_tool', fileName));
      if (candidate.existsSync()) {
        return candidate;
      }
      if (!ascend) {
        break;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    throw FileSystemException(
      'Could not find `.dart_tool/$fileName` in "$rootPackageDir"'
      '${ascend ? ' or any of its parent directories' : ''}. '
      'Run `dart pub get` first.',
    );
  }

  /// Loads and parses the `.dart_tool/package_graph.json` file.
  _PackageGraphFile _loadPackageGraphFile({required bool ascend}) {
    final file = _findDartToolFile('package_graph.json', ascend: ascend);
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _PackageGraphFile.fromJson(json);
  }

  /// Loads and parses the `.dart_tool/package_config.json` file.
  _PackageConfigFile _loadPackageConfigFile({required bool ascend}) {
    final file = _findDartToolFile('package_config.json', ascend: ascend);
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
    return loadPubspecAt(packageName, entry.rootUri.toFilePath());
  }

  /// Loads and parses `pubspec.yaml` for [packageName] at [packageRootPath].
  @protected
  parse.Pubspec? loadPubspecAt(String packageName, String packageRootPath) {
    final pubspecFile = File(p.join(packageRootPath, 'pubspec.yaml'));
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
        return Dependency.extractConstraint(pubspec.devDependencies[depName]!);
      }
    } else {
      if (pubspec.dependencies.containsKey(depName)) {
        return Dependency.extractConstraint(pubspec.dependencies[depName]!);
      }
      if (pubspec.dependencyOverrides.containsKey(depName)) {
        return Dependency.extractConstraint(
          pubspec.dependencyOverrides[depName]!,
        );
      }
    }
    return VersionConstraint.empty;
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
    final ascend = pubspec.resolution == 'workspace';
    final graphFile = _loadPackageGraphFile(ascend: ascend);
    final configFile = _loadPackageConfigFile(ascend: ascend);

    final map = SplayTreeMap<String, VizPackage>();
    final pendingTransitive = Queue<String>();
    final pubspecCache = <String, parse.Pubspec?>{pubspec.name: pubspec};

    parse.Pubspec? getPubspec(String name) => pubspecCache.putIfAbsent(
      name,
      () => _loadPubspecForPackage(name, configFile),
    );

    final primaryRoots = includeWorkspace && graphFile.roots.isNotEmpty
        ? graphFile.roots.toSet()
        : {pubspec.name};

    for (final rootName in primaryRoots) {
      final pkg = _buildPrimaryPackage(
        rootName,
        rootPubspec: pubspec,
        graphEntry: graphFile.packages[rootName],
        memberPubspec: getPubspec(rootName),
        flagOutdated: flagOutdated,
        productionDependenciesOnly: productionDependenciesOnly,
        includeWorkspace: includeWorkspace,
      );
      map[rootName] = pkg;
      for (final dep in pkg.dependencies) {
        pendingTransitive.add(dep.name);
      }
    }

    while (pendingTransitive.isNotEmpty) {
      final name = pendingTransitive.removeFirst();
      if (map.containsKey(name)) continue;

      final pkg = _buildTransitivePackage(
        name,
        graphFile: graphFile,
        pkgPubspec: getPubspec(name),
        flagOutdated: flagOutdated,
      );
      map[name] = pkg;

      if (!directDependenciesOnly) {
        pendingTransitive.addAll(pkg.dependencies.map((d) => d.name));
      }
    }

    return map;
  }

  VizPackage _buildPrimaryPackage(
    String rootName, {
    required parse.Pubspec rootPubspec,
    required _PackageGraphPackage? graphEntry,
    required parse.Pubspec? memberPubspec,
    required bool flagOutdated,
    required bool productionDependenciesOnly,
    required bool includeWorkspace,
  }) {
    final effectivePubspec =
        memberPubspec ?? (rootName == rootPubspec.name ? rootPubspec : null);
    final prodDepNames =
        graphEntry?.dependencies ??
        effectivePubspec?.dependencies.keys ??
        const <String>[];
    final dependencies = _buildDependencies(
      prodDepNames,
      effectivePubspec,
      isDev: false,
    );

    if (!productionDependenciesOnly) {
      final devDepNames =
          graphEntry?.devDependencies ??
          effectivePubspec?.devDependencies.keys ??
          const <String>[];
      dependencies.addAll(
        _buildDependencies(devDepNames, effectivePubspec, isDev: true),
      );
    }

    final isPublishToNone = effectivePubspec?.publishTo == 'none';
    final version = _resolvePrimaryVersion(
      rootName: rootName,
      rootPubspecName: rootPubspec.name,
      includeWorkspace: includeWorkspace,
      isPublishToNone: isPublishToNone,
      graphEntry: graphEntry,
      memberPubspec: effectivePubspec,
    );

    return VizPackage(
      rootName,
      version,
      SplayTreeSet.of(dependencies),
      includeWorkspace && flagOutdated ? _latest(rootName) : null,
      isPrimary: true,
      onlyDev: false,
      isPublishToNone: isPublishToNone,
    );
  }

  Version? _resolvePrimaryVersion({
    required String rootName,
    required String rootPubspecName,
    required bool includeWorkspace,
    required bool isPublishToNone,
    required _PackageGraphPackage? graphEntry,
    required parse.Pubspec? memberPubspec,
  }) {
    if (!includeWorkspace) {
      return memberPubspec?.version;
    }
    if (rootName == rootPubspecName || isPublishToNone) {
      return null;
    }
    return graphEntry?.version ?? memberPubspec?.version;
  }

  VizPackage _buildTransitivePackage(
    String name, {
    required _PackageGraphFile graphFile,
    required parse.Pubspec? pkgPubspec,
    required bool flagOutdated,
  }) {
    final graphEntry = graphFile.packages[name];
    if (graphEntry == null) {
      throw StateError('Could not find an entry for `$name`.');
    }

    final dependencies = _buildDependencies(
      graphEntry.dependencies,
      pkgPubspec,
      isDev: false,
    );

    return VizPackage(
      name,
      graphEntry.version ?? pkgPubspec?.version,
      SplayTreeSet.of(dependencies),
      flagOutdated ? _latest(name) : null,
      isPublishToNone: pkgPubspec?.publishTo == 'none',
    );
  }

  Set<Dependency> _buildDependencies(
    Iterable<String> depNames,
    parse.Pubspec? pubspec, {
    required bool isDev,
  }) => {
    for (final depName in depNames)
      if (!_ignoredPackages.contains(depName))
        Dependency(
          depName,
          _getConstraint(pubspec, depName, isDev: isDev),
          isDev,
        ),
  };

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

  _PackageGraphPackage({
    required this.name,
    this.version,
    required this.dependencies,
    required this.devDependencies,
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

    return _PackageGraphPackage(
      name: name,
      version: version,
      dependencies: dependencies,
      devDependencies: devDependencies,
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

  _PackageConfigEntry({required this.name, required this.rootUri});

  factory _PackageConfigEntry.fromJson(
    Map<String, dynamic> json, {
    required Uri baseUri,
  }) {
    final name = json['name'] as String;
    final rawRootUri = json['rootUri'] as String;
    final resolvedRoot = baseUri.resolve(rawRootUri);

    return _PackageConfigEntry(name: name, rootUri: resolvedRoot);
  }
}
