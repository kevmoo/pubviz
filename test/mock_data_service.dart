import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubviz/src/deps_list.dart';
import 'package:pubviz/src/service.dart';

class MockDataService extends Service {
  @override
  final String rootPackageDir;

  MockDataService(this.rootPackageDir);

  @override
  Map<String, dynamic> outdated() {
    final file = File(p.join(rootPackageDir, 'outdated.json'));
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  DepsList? _depsListCache;

  DepsList _getDepsList() {
    if (_depsListCache == null) {
      final depsFile = File(p.join(rootPackageDir, 'pub_deps_list.txt'));
      _depsListCache = DepsList.parse(depsFile.readAsStringSync());
    }
    return _depsListCache!;
  }

  @override
  DepsPackageEntry rootDeps() => _getDepsList().packages[rootPubspec().name]!;

  @override
  Iterable<DepsPackageEntry> allDeps() => _getDepsList().packages.values;

  @override
  Future<Map<String, String>> workspaceMembers() async {
    final file = File(p.join(rootPackageDir, 'workspace_list.json'));
    if (!file.existsSync()) {
      return {rootPubspec().name: rootPackageDir};
    }

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final packages = json['packages'] as List;
    return {
      for (var pkgEntry in packages.cast<Map<String, dynamic>>())
        pkgEntry['name'] as String: p.canonicalize(
          p.join(rootPackageDir, pkgEntry['path'] as String),
        ),
    };
  }
}
