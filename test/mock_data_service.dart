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

  @override
  DepsList rootDeps() {
    final depsFile = File(p.join(rootPackageDir, 'pub_deps_list.txt'));
    return DepsList.parse(depsFile.readAsStringSync());
  }
}
