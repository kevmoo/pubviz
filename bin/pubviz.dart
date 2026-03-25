#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/src/executable.dart' as exec;
import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/version.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> main(List<String> args) async {
  await overrideAnsiOutput(stderr.supportsAnsiEscapes, () async {
    await _main(args);
  });
}

Future<void> _main(List<String> args) async {
  Options options;
  try {
    options = parseOptions(args);
  } on FormatException catch (e) {
    print(red.wrap(e.message));
    print('');
    _printUsage();
    exitCode = ExitCode.usage.code;
    return;
  }

  if (options.help) {
    _printUsage();
    return;
  }

  if (options.version) {
    print(packageVersion);
    return;
  }

  String path;
  try {
    path = _getPath(options.rest);
    // ignore: avoid_catching_errors
  } on StateError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
    return;
  }

  await Chain.capture(
    () async {
      await exec.run(options, path);
    },
    onError: (error, Chain chain) {
      stderr
        ..writeln(error)
        ..writeln(chain.terse);
      exitCode = 1;
    },
  );
}

String _indent(String input) =>
    LineSplitter.split(input).map((l) => '  $l'.trimRight()).join('\n');

void _printUsage() {
  print('''Usage: pubviz [<args>] [<package path>]

${styleBold.wrap('Arguments:')}
${_indent(parser.usage)}

If <package path> is omitted, the current directory is used.''');
}

String _getPath(List<String> args) {
  if (args.length > 1) {
    throw StateError(
      'Only one argument is allowed. You provided ${args.length}.',
    );
  }

  final path = args.isEmpty ? p.current : args.first;

  if (!FileSystemEntity.isDirectorySync(path)) {
    throw StateError(
      'The provided path does not exist or is not a directory: $path',
    );
  }

  final yamlPath = p.join(path, 'pubspec.yaml');

  if (!FileSystemEntity.isFileSync(yamlPath)) {
    throw StateError(
      'Could not find a pubspec.yaml in the target path.: $path',
    );
  }

  return path;
}
