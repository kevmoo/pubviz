import 'dart:collection';

import 'package:path/path.dart' as p;

import 'service.dart';
import 'viz_package.dart';

class Worker {
  final Service _service;

  Worker(this._service);

  Future<Map<String, VizPackage>> getReferencedPackages(
    String path,
    bool flagOutdated,
    bool directDependencies,
  ) async {
    final packs = SplayTreeMap<String, VizPackage>();

    final map = _packageMap(path, directDependencies);

    // TODO(kevmoo): consider a pool here!
    final futures = map.keys.map((packageName) async {
      final subPath = map[packageName];
      final vp = await VizPackage.forDirectory(
        _service,
        subPath,
        flagOutdated: flagOutdated,
      );
      assert(vp.name == packageName);

      assert(!packs.containsKey(vp.name));
      assert(!packs.containsValue(vp));
      packs[vp.name] = vp;
    });

    await Future.wait(futures);

    return packs;
  }

  Map<String, String> _packageMap(String path, bool directDependencies) {
    final json = _service.listPackageDirs(path);

    var packageEntries = (json['packages'] as Map<String, dynamic>).entries;

    if (directDependencies) {
      final pubspec = _service.pubspecForDirectory(path);

      packageEntries = packageEntries.where(
        (entry) =>
            pubspec.dependencies.containsKey(entry.key) ||
            entry.key == pubspec.name,
      );
    }

    final map = <String, String>{};

    for (var entry in packageEntries) {
      assert(p.basename(entry.value as String) == 'lib');
      map[entry.key] = p.dirname(entry.value as String);
    }

    return map;
  }
}
