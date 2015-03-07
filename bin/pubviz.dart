#!/usr/bin/env dart
import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';

void main(List<String> args) {
  var parser = _getParser();

  var result = parser.parse(args);

  var command = result.command;

  if (command == null) {
    _printUsage(parser);
    return;
  }

  var path = _getPath(command.rest);

  var format = result['format'];

  VizRoot.forDirectory(path).then((VizRoot vp) {
    if (command.name == 'print') {
      _printContent(vp, format);
    } else if (command.name == 'open') {
      _open(vp, format);
    } else {
      throw new StateError('Should never get here...');
    }
  });
}

void _printUsage(ArgParser parser) {
  print('usage: pubviz [--format=<format>] (open | print) [<package path>]');
  print('');
  print('  open   Populate a temporary file with the content and open it.');
  print('  print  Print the output to stdout.');
  print('');
  print(parser.usage);
  print('');
  print('If <package path> is omitted, the current directory is used.');
}

String _getContent(VizRoot root, String format) {
  switch (format) {
    case 'html':
      return _getHtmlContent(root);
    case 'dot':
      return root.toDot();
    default:
      throw new StateError('format "$format" is not supported');
  }
}

Future _open(VizRoot root, String format) {
  String filePath;

  var name = root.root.name;

  String content = _getContent(root, format);

  return Directory.systemTemp.createTemp('pubviz_${name}_').then((dir) {
    var extention = (format == 'html') ? 'html' : 'dot';
    filePath = p.join(dir.path, '$name.$extention');
    var file = new File(filePath);
    return file.create();
  }).then((file) {
    return file.writeAsString(content, mode: FileMode.WRITE, flush: true);
  }).then((_) {
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
  });
}

void _printContent(VizRoot root, String format) {
  var content = _getContent(root, format);
  print(content);
}

String _getHtmlContent(VizRoot root) {
  var dot = root.toDot(escapeLabels: true);

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
  ..addCommand('open')
  ..addCommand('print');

const DOT_PLACE_HOLDER = 'DOT_HERE';

const TITLE_PLACE_HOLDER = 'PACKAGE_TITLE';

const _FORMAT_ALLOWED = const ['html', 'dot'];

const _FORMAT_HELP = const {
  'dot': 'Generate a GraphViz dot file',
  'html': 'Wrap the GraphViz dot format in an HTML template which renders it.'
};
