#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:io/io.dart';
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

  try {
    await exec.run(options);
  } on exec.UsageException catch (e) {
    print(red.wrap(e.message));
    print('');
    _printUsage();
    exitCode = ExitCode.usage.code;
  } catch (error, stack) {
    stderr.write('''
$error

${Chain.forTrace(stack).terse}''');
    exitCode = 1;
  }
}

String _indent(String input) =>
    LineSplitter.split(input).map((l) => '  $l'.trimRight()).join('\n');

void _printUsage() {
  print('''Usage: pubviz [<args>] [<package path>]

${styleBold.wrap('Arguments:')}
${_indent(parser.usage)}

If <package path> is omitted, the current directory is used.''');
}
