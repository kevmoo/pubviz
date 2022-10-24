// copied from https://github.com/dart-lang/pana/blob/0aca0eb21fe30ef27d625aad0836911a29d02984/lib/src/pubspec.dart
// ...then heavily pruned

import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart' as pubspek show Pubspec;
import 'package:pubspec_parse/pubspec_parse.dart' hide Pubspec;
import 'package:yaml/yaml.dart' as yaml;

bool isFlutterPackage(String packageDir) {
  final path = p.join(packageDir, 'pubspec.yaml');

  final map = yaml.loadYaml(
    File(path).readAsStringSync(),
    sourceUrl: Uri.parse(path),
  ) as yaml.YamlMap;

  final pubspec = _Pubspec(map);

  return pubspec.usesFlutter;
}

class _Pubspec {
  final pubspek.Pubspec _inner;
  final yaml.YamlMap _content;

  Set<String>? _dependentSdks;

  _Pubspec(this._content)
      : _inner = pubspek.Pubspec.fromJson(_content, lenient: true);

  Map<String, Dependency> get dependencies => _inner.dependencies;

  Map<String, Dependency> get devDependencies => _inner.devDependencies;

  bool dependsOnPackage(String package) =>
      (dependencies.containsKey(package)) ||
      (devDependencies.containsKey(package));

  bool get hasFlutterKey => _content.containsKey('flutter');

  bool get hasFlutterPluginKey =>
      hasFlutterKey &&
      _content['flutter'] is Map &&
      (_content['flutter'] as Map)['plugin'] != null;

  bool get dependsOnFlutterSdk => dependentSdks.contains('flutter');

  bool get dependsOnFlutterPackage => dependsOnPackage('flutter');

  bool get usesFlutter =>
      dependsOnFlutterSdk || dependsOnFlutterPackage || hasFlutterKey;

  Set<String> get dependentSdks {
    if (_dependentSdks == null) {
      _dependentSdks = SplayTreeSet();
      // ignore: avoid_function_literals_in_foreach_calls
      dependencies.values.forEach((value) {
        if (value is SdkDependency) {
          _dependentSdks!.add(value.sdk);
        }
      });
      // ignore: avoid_function_literals_in_foreach_calls
      devDependencies.values.forEach((value) {
        if (value is SdkDependency) {
          _dependentSdks!.add(value.sdk);
        }
      });
      if (_inner.environment != null) {
        final keys = _inner.environment!.keys.toList()..remove('sdk');
        _dependentSdks!.addAll(keys);
      }
    }
    return _dependentSdks!;
  }
}
