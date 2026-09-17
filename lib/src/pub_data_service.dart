import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_util.dart';

import 'service.dart';

/// Service implementation that retrieves package information by invoking the
/// pub CLI.
final class PubDataService extends Service {
  @override
  final String rootPackageDir;
  final bool _debug;

  /// Creates a [PubDataService] operating on [rootPackageDir].
  PubDataService(this.rootPackageDir, {this._debug = false});

  @override
  Map<String, dynamic> outdated() {
    final commandOutput = _pubCommand(['outdated', '--json']);

    try {
      return jsonDecode(commandOutput) as Map<String, dynamic>;
    } on FormatException {
      stderr
        ..writeln('JSON output from `pub` command was invalid.')
        ..writeln(
          LineSplitter.split(commandOutput).map((e) => '  $e\n').join(),
        );
      rethrow;
    }
  }

  String _pubCommand(List<String> commandArgs) {
    final proc = dartExecutable ?? 'dart';
    final args = [
      ...['pub'],
      ...commandArgs,
    ];

    _print([proc, ...args].join(' '));
    _print('  in path `$rootPackageDir`');

    final pubEnv = <String>[];
    if (Platform.environment.containsKey(_pubEnvironment)) {
      final value = Platform.environment[_pubEnvironment]!.trim();
      if (value.isNotEmpty) {
        pubEnv.add(value);
      }
    }
    pubEnv.add('pkg.pubviz');

    final environment = <String, String>{_pubEnvironment: pubEnv.join(':')};

    final result = Process.runSync(
      proc,
      args,
      workingDirectory: rootPackageDir,
      environment: environment,
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

      throw ProcessException(proc, args, message, result.exitCode);
    }

    return result.stdout as String;
  }

  void _print(Object value) {
    if (_debug) {
      stderr.writeln('  $value');
    }
  }
}

const _pubEnvironment = 'PUB_ENVIRONMENT';
