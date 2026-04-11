import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

const assetFileName = 'build_inputs.json';

const _inputs = {'web', 'build.yaml', 'lib', 'pubspec.yaml'};

Future<String> hashInputs() async {
  final gitLs = await Process.run('git', ['ls-files', ..._inputs]);
  if (gitLs.exitCode != 0) {
    throw StateError('git ls-files failed');
  }

  final files =
      (gitLs.stdout as String).split('\n').where((s) => s.isNotEmpty).toList()
        ..sort();

  final regexes = _getLibSrcRegexes();

  final map = <String, String>{};
  for (final file in files) {
    if (file.startsWith('lib/assets/')) continue;
    if (file == 'web/viz_data.js') continue;

    if (file.startsWith('lib/src/')) {
      final matches = regexes.any((r) => r.hasMatch(file));
      if (!matches) continue;
    }

    final stream = File(file).openRead();
    final digest = await sha256.bind(stream).first;
    map[file] = digest.toString();
  }
  return const JsonEncoder.withIndent('  ').convert(map);
}

// TODO: consider just moving the "io" bits into a different directory
/// Parses `build.yaml` to extract the list of files under `lib/src/` that are
/// defined as sources for the default target.
///
/// Converts glob-style paths structure (e.g., `lib/src/opts.*`) into [RegExp]
/// formats suitable for exact path boundary validation.
List<RegExp> _getLibSrcRegexes() {
  final buildYamlString = File('build.yaml').readAsStringSync();
  final buildYaml = loadYaml(buildYamlString);

  if (buildYaml case {
    'targets': {r'$default': {'sources': final List<dynamic> sourcesList}},
  }) {
    final sources = sourcesList.cast<String>();

    return sources
        .where((s) => s.startsWith('lib/src/'))
        .map(
          (s) => RegExp('^${s.replaceAll('.', r'\.').replaceAll('*', '.*')}\$'),
        )
        .toList();
  }

  throw StateError('Could not parse sources from build.yaml');
}
