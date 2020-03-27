import 'dart:convert';
import 'dart:io';

import 'service.dart';

class PubDataService extends Service {
  @override
  final String rootPackageDir;
  final bool _debug;

  PubDataService(this.rootPackageDir, {bool debug = false})
      : _debug = debug ?? false;

  @override
  Map<String, dynamic> listPackageDirs(String directory) =>
      _pubJsonCommand(directory, ['list-package-dirs']);

  @override
  Map<String, dynamic> outdated() =>
      _pubJsonCommand(rootPackageDir, ['outdated', '--format=json']);

  Map<String, dynamic> _pubJsonCommand(String path, List<String> commandArgs) {
    try {
      return _pubJsonCommandCore(path, commandArgs, false);
    } on ProcessException catch (e) {
      if (e.message.startsWith('Flutter is not available.') ||
          e.message.startsWith('The Flutter SDK is not available.')) {
        return _pubJsonCommandCore(path, commandArgs, true);
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> _pubJsonCommandCore(
    String path,
    List<String> commandArgs,
    bool withFlutter,
  ) {
    final proc = withFlutter ? 'flutter' : 'pub';
    final args = [
      if (withFlutter) ...['packages', 'pub'],
      ...commandArgs
    ];

    _print([proc, ...args].join(' '));
    _print('  in path `$path`');

    final result = Process.runSync(
      proc,
      args,
      runInShell: true,
      workingDirectory: path,
    );

    if (result.exitCode != 0) {
      var message = result.stderr as String;
      try {
        final value = jsonDecode(result.stdout as String) as Map;
        if (value.containsKey('error')) {
          message = value['error'] as String;
        }
      } catch (e) {
        // NOOP
      }

      throw ProcessException(
        proc,
        args,
        message,
        result.exitCode,
      );
    }

    try {
      return jsonDecode(result.stdout as String) as Map<String, dynamic>;
    } on FormatException {
      stderr
        ..writeln('JSON output from `pub` command was invalid.')
        ..writeln(
          LineSplitter.split(result.stdout as String)
              .map((e) => '  $e\n')
              .join(),
        );
      rethrow;
    }
  }

  void _print(Object value) {
    if (_debug) {
      stderr.writeln('  $value');
    }
  }
}
