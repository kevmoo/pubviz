import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart' as parse;
import 'package:pubviz/src/service.dart';

final class MockDataService extends Service {
  Map<String, dynamic>? _packagePubspecsCache;

  @override
  final String rootPackageDir;

  MockDataService(this.rootPackageDir);

  @override
  parse.Pubspec? loadPubspecAt(String packageName, String packageRootPath) {
    final fromDisk = super.loadPubspecAt(packageName, packageRootPath);
    if (fromDisk != null) return fromDisk;

    _packagePubspecsCache ??= _loadPackagePubspecs();
    final deps = _packagePubspecsCache?[packageName];
    if (deps is! Map) return null;

    final yamlBuffer = StringBuffer('name: $packageName\ndependencies:\n');
    for (final entry in deps.cast<String, dynamic>().entries) {
      yamlBuffer.writeln('  ${entry.key}: "${entry.value}"');
    }
    return parse.Pubspec.parse(yamlBuffer.toString());
  }

  Map<String, dynamic> _loadPackagePubspecs() {
    final file = File(p.join(rootPackageDir, 'package_pubspecs.json'));
    if (!file.existsSync()) return const {};
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> outdated() {
    final file = File(p.join(rootPackageDir, 'outdated.json'));
    if (!file.existsSync()) {
      return {'packages': <void>[]};
    }
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}
