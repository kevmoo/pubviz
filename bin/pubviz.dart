#!/usr/bin/env dart
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';

main(List<String> args) async {
  var parser = _getParser();

  var result;
  try {
    result = parser.parse(args);
  } on FormatException catch (e) {
    print(e.message);
    _printUsage(parser);
    return;
  }

  var command = result.command;

  if (command == null) {
    _printUsage(parser);
    return;
  }

  var path = _getPath(command.rest);

  var format = result['format'];
  var flagOutdated = result['flag-outdated'];
  var ignorePackages = result['ignore-packages'] != null
      ? result['ignore-packages'].map((e) => e.trim()).toList()
      : const [];

  var vp = await VizRoot.forDirectory(path,
      flagOutdated: flagOutdated, ignorePackages: ignorePackages);
  if (command.name == 'print') {
    _printContent(vp, format, ignorePackages);
  } else if (command.name == 'open') {
    await _open(vp, format, ignorePackages);
  } else {
    throw new StateError('Should never get here...');
  }
}

void _printUsage(ArgParser parser) {
  print(
      'usage: pubviz [--format=<format>] [--ignore=<package1>,<package2>] (open | print) [<package path>]');
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
      return _getHtmlContent(root, ignorePackages: ignorePackages);
    case 'dot':
      return root.toDot(ignorePackages: ignorePackages);
    default:
      throw new StateError('format "$format" is not supported');
  }
}

Future _open(VizRoot root, String format, List<String> ignorePackages) async {
  String filePath;

  var name = root.root.name;

  String content = _getContent(root, format, ignorePackages);

  var dir = await Directory.systemTemp.createTemp('pubviz_${name}_');
  var extention = (format == 'html') ? 'html' : 'dot';
  filePath = p.join(dir.path, '$name.$extention');
  var file = new File(filePath);

  file = await file.create();
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

String _getHtmlContent(VizRoot root, {List<String> ignorePackages: const []}) {
  var dot = root.toDot(escapeLabels: true, ignorePackages: ignorePackages);

  var content = TEMPLATE;
  content = content.replaceAll(DOT_PLACE_HOLDER, dot);
  content = content.replaceAll(TITLE_PLACE_HOLDER, root.root.name);

  return content;
}

String _getPath(List<String> args) {
  if (args.length > 1) {
    print("Only one argument is allowed. You provided ${args.length}.");
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

ArgParser _getParser() => new ArgParser()
  ..addOption('format',
      abbr: 'f',
      allowed: _FORMAT_ALLOWED,
      defaultsTo: 'html',
      allowedHelp: _FORMAT_HELP)
  ..addOption('ignore-packages',
      abbr: 'i',
      help: 'A comma seperatedlist of packages to not include in the output.',
      allowMultiple: true)
  ..addCommand('open')
  ..addCommand('print')
  ..addFlag('flag-outdated',
      abbr: 'o',
      defaultsTo: false,
      negatable: true,
      help: 'Check pub.dartlang.org for lasted packages and flag those that '
      'are outdated.');

const DOT_PLACE_HOLDER = 'DOT_HERE';

const TITLE_PLACE_HOLDER = 'PACKAGE_TITLE';

const _FORMAT_ALLOWED = const ['html', 'dot'];

const _FORMAT_HELP = const {
  'dot': 'Generate a GraphViz dot file',
  'html': 'Wrap the GraphViz dot format in an HTML template which renders it.'
};
