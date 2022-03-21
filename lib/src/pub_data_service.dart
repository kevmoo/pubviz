import 'dart:convert';
import 'dart:io';

import 'deps_list.dart';
import 'pubspek.dart';
import 'service.dart';

class PubDataService extends Service {
  @override
  final String rootPackageDir;
  final bool _debug;
  final bool _isFlutterPkg;

  PubDataService(this.rootPackageDir, {bool debug = false})
      : _debug = debug,
        _isFlutterPkg = isFlutterPackage(rootPackageDir);

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

  @override
  DepsList rootDeps() {
    final commandOutput = _pubCommand(['deps', '-s', 'list']);
    return DepsList.parse(commandOutput);
  }

  String _pubCommand(List<String> commandArgs) {
    final proc = _isFlutterPkg ? 'flutter' : 'dart';
    final args = [
      ...['pub'],
      ...commandArgs
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

    final environment = <String, String>{
      _pubEnvironment: pubEnv.join(':'),
    };

    final result = Process.runSync(
      proc,
      args,
      runInShell: true,
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

      throw ProcessException(
        proc,
        args,
        message,
        result.exitCode,
      );
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
