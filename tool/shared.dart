import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const assetFileName = 'build_inputs.json';

const _inputs = {'_example_src', 'build.yaml', 'lib', 'pubspec.yaml'};

Future<String> hashInputs() async {
  final gitLs = await Process.run('git', ['ls-files', ..._inputs]);
  if (gitLs.exitCode != 0) {
    throw StateError('git ls-files failed');
  }

  final files =
      (gitLs.stdout as String).split('\n').where((s) => s.isNotEmpty).toList()
        ..sort();

  final map = <String, String>{};
  for (final file in files) {
    if (file.startsWith('lib/assets/')) continue;
    final stream = File(file).openRead();
    final digest = await sha256.bind(stream).first;
    map[file] = digest.toString();
  }
  return const JsonEncoder.withIndent('  ').convert(map);
}
