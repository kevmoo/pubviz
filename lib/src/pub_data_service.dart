import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'deps_list.dart';
import 'service.dart';

class PubDataService extends Service {
  @override
  final String rootPackageDir;
  final bool _debug;

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

  late final _depsListCache = DepsList.fromJson(
    jsonDecode(_pubCommand(['deps', '--json'])) as Map<String, dynamic>,
  );

  @override
  DepsPackageEntry rootDeps() => _depsListCache.rootPackage;

  @override
  Iterable<DepsPackageEntry> allDeps() => _depsListCache.packages.values;

  @override
  Future<Map<String, String>> workspaceMembers() async {
    final commandOutput = _pubCommand(['workspace', 'list', '--json']);
    return switch (jsonDecode(commandOutput)) {
      {'packages': final List<dynamic> packages} => {
        for (final p in packages)
          if (p case {'name': final String name, 'path': final String path})
            name: path,
      },
      _ => throw StateError('Unexpected output from `pub workspace list`.'),
    };
  }

  String _pubCommand(List<String> commandArgs) {
    final proc = dartExecutable();
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

String dartExecutable({
  Uri? script,
  String? resolvedExecutable,
  String? version,
  Map<String, String>? environment,
}) {
  script ??= Platform.script;
  resolvedExecutable ??= Platform.resolvedExecutable;
  version ??= Platform.version;
  environment ??= Platform.environment;

  final isCompiledExe =
      version.contains('(exe)') ||
      (script.isScheme('file') && script.toFilePath() == resolvedExecutable) ||
      p.basenameWithoutExtension(resolvedExecutable).toLowerCase() != 'dart';

  if (isCompiledExe) {
    final exeName = Platform.isWindows ? 'dart.exe' : 'dart';
    if (environment.containsKey('FLUTTER_ROOT')) {
      final flutterDart = p.join(
        environment['FLUTTER_ROOT']!,
        'bin',
        'cache',
        'dart-sdk',
        'bin',
        exeName,
      );
      if (File(flutterDart).existsSync()) {
        return flutterDart;
      }
    }
    if (environment.containsKey('DART_SDK')) {
      final sdkDart = p.join(environment['DART_SDK']!, 'bin', exeName);
      if (File(sdkDart).existsSync()) {
        return sdkDart;
      }
    }
    return exeName;
  }
  return resolvedExecutable;
}
