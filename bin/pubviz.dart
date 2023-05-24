#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/version.dart';
import 'package:pubviz/viz/dot.dart' as dot;
import 'package:stack_trace/stack_trace.dart';

Future<void> main(List<String> args) async {
  parser
    ..addCommand('open')
    ..addCommand('print');

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

  final command = options.command;

  if (command == null) {
    print(red.wrap("Specify a command: ${parser.commands.keys.join(', ')}"));
    print('');
    _printUsage();
    exitCode = ExitCode.usage.code;
    return;
  }

  final path = _getPath(command.rest);

  await Chain.capture(
    () async {
      final service = PubDataService(path);
      final vp = await VizRoot.forDirectory(
        service,
        flagOutdated: options.flagOutdated,
        ignorePackages: options.ignorePackages,
        directDependenciesOnly: options.directDependencies ?? false,
        productionDependenciesOnly: options.productionDependencies,
      );
      if (command.name == 'print') {
        _printContent(vp, options.format, options.ignorePackages);
      } else if (command.name == 'open') {
        await _open(vp, options.format, options.ignorePackages);
      } else {
        throw StateError('Should never get here...');
      }
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
  print(
    '''Usage: pubviz [<args>] <command> [<package path>]

${styleBold.wrap('Commands:')}
  open   Populate a temporary file with the content and open it.
  print  Print the output to stdout.

${styleBold.wrap('Arguments:')}
${_indent(parser.usage)}

If <package path> is omitted, the current directory is used.''',
  );
}

String _getContent(
  VizRoot root,
  FormatOptions format,
  List<String> ignorePackages,
) =>
    switch (format) {
      FormatOptions.html => dot.toDotHtml(root, ignorePackages: ignorePackages),
      FormatOptions.dot => dot.toDot(root, ignorePackages: ignorePackages)
    };

String _getExtension(FormatOptions format) => format.toString().split('.')[1];

Future<void> _open(
  VizRoot root,
  FormatOptions format,
  List<String> ignorePackages,
) async {
  final extension = _getExtension(format);
  final name = root.root.name;
  final dir = await Directory.systemTemp.createTemp('pubviz_${name}_');
  final filePath = p.join(dir.path, '$name.$extension');
  var file = File(filePath);

  file = await file.create();
  final content = _getContent(root, format, ignorePackages);
  await file.writeAsString(content, flush: true);

  print('File generated: $filePath');

  String openCommand;
  if (Platform.isMacOS) {
    openCommand = 'open';
  } else if (Platform.isLinux) {
    openCommand = 'xdg-open';
  } else if (Platform.isWindows) {
    openCommand = 'start';
  } else {
    print("We don't know how to open a file in ${Platform.operatingSystem}");
    exit(1);
  }

  await Process.run(openCommand, [filePath], runInShell: true);
}

void _printContent(
  VizRoot root,
  FormatOptions format,
  List<String> ignorePackages,
) {
  final content = _getContent(root, format, ignorePackages);
  print(content);
}

String _getPath(List<String> args) {
  if (args.length > 1) {
    print('Only one argument is allowed. You provided ${args.length}.');
    exit(1);
  }

  final path = args.isEmpty ? p.current : args.first;

  if (!FileSystemEntity.isDirectorySync(path)) {
    print('The provided path does not exist or is not a directory: $path');
    exit(1);
  }

  final yamlPath = p.join(path, 'pubspec.yaml');

  if (!FileSystemEntity.isFileSync(yamlPath)) {
    print('Could not find a pubspec.yaml in the target path.: $path');
    exit(1);
  }

  return path;
}
