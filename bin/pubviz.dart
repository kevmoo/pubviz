#!/usr/bin/env dart
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/viz/dot.dart' as dot;
import 'package:stack_trace/stack_trace.dart';

main(List<String> args) async {
  var parser = _getParser();

  ArgResults result;
  try {
    result = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    _printUsage(parser);
    return;
  }

  var command = result.command;

  if (command == null) {
    print("Specify a command: ${parser.commands.keys.join(', ')}");
    _printUsage(parser);
    return;
  }

  var path = _getPath(command.rest);

  var format = result[_formatOption] as String;
  var flagOutdated = result['flag-outdated'] as bool;
  List<String> ignorePackages = result['ignore-packages'] != null
      ? result[_ignoreOption].map((e) => e.trim()).toList()
      : const [];

  await Chain.capture(() async {
    var vp = await VizRoot.forDirectory(path,
        flagOutdated: flagOutdated, ignorePackages: ignorePackages);
    if (command.name == 'print') {
      _printContent(vp, format, ignorePackages);
    } else if (command.name == 'open') {
      await _open(vp, format, ignorePackages);
    } else {
      throw new StateError('Should never get here...');
    }
  }, onError: (error, Chain chain) {
    stderr.writeln(error);
    stderr.writeln(chain.terse);
    exitCode = 1;
  });
}

void _printUsage(ArgParser parser) {
  print('usage: pubviz [--$_formatOption=<format>] '
      '[--$_ignoreOption=<package1>,<package2>] '
      '(open | print) [<package path>]');
  print('');
  print('  open   Populate a temporary file with the content and open it.');
  print('  print  Print the output to stdout.');
  print('');
  print(parser.usage);
  print('');
  print('If <package path> is omitted, the current directory is used.');
}

String _getContent(VizRoot root, String format, List<String> ignorePackages) {
  switch (format) {
    case 'html':
      return dot.toDotHtml(root, ignorePackages: ignorePackages);
    case 'dot':
      return dot.toDot(root, ignorePackages: ignorePackages);
    default:
      throw new StateError('format "$format" is not supported');
  }
}

String _getExtension(String format) {
  switch (format) {
    default:
      return format;
  }
}

Future _open(VizRoot root, String format, List<String> ignorePackages) async {
  var extension = _getExtension(format);
  var name = root.root.name;
  var dir = await Directory.systemTemp.createTemp('pubviz_${name}_');
  var filePath = p.join(dir.path, '$name.$extension');
  var file = new File(filePath);

  file = await file.create();
  String content = _getContent(root, format, ignorePackages);
  await file.writeAsString(content, mode: FileMode.WRITE, flush: true);

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

  return Process.run(openCommand, [filePath], runInShell: true);
}

void _printContent(VizRoot root, String format, List<String> ignorePackages) {
  var content = _getContent(root, format, ignorePackages);
  print(content);
}

String _getPath(List<String> args) {
  if (args.length > 1) {
    print('Only one argument is allowed. You provided ${args.length}.');
    exit(1);
  }

  var path = args.isEmpty ? p.current : args.first;

  if (!FileSystemEntity.isDirectorySync(path)) {
    print('The provided path does not exist or is not a directory: $path');
    exit(1);
  }

  var yamlPath = p.join(path, 'pubspec.yaml');

  if (!FileSystemEntity.isFileSync(yamlPath)) {
    print('Could not find a pubspec.yaml in the target path.: $path');
    exit(1);
  }

  return path;
}

const _formatOption = 'format';
const _ignoreOption = 'ignore-packages';

ArgParser _getParser() => new ArgParser(allowTrailingOptions: true)
  ..addOption(_formatOption,
      abbr: 'f',
      allowed: _formatHelp.keys.toList(),
      defaultsTo: 'html',
      allowedHelp: _formatHelp)
  ..addOption(_ignoreOption,
      abbr: 'i',
      help: 'A comma seperated list of packages to exclude in the output.',
      allowMultiple: true)
  ..addCommand('open')
  ..addCommand('print')
  ..addFlag('flag-outdated',
      abbr: 'o',
      defaultsTo: false,
      negatable: true,
      help: 'Check pub.dartlang.org for lasted packages and flag those that '
          'are outdated.');

const _formatHelp = const {
  'dot': 'Generate a GraphViz dot file',
  'html': 'Wrap the GraphViz dot format in an HTML template which renders it.'
};
