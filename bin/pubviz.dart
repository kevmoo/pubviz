#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:pubviz/pubviz.dart';
import 'package:args/args.dart';

void main(List<String> args) {
  var parser = _getParser();

  var result = parser.parse(args);
  bool html = result['html'];

  final path = _getPath(result.rest);

  VizRoot.forDirectory(path)
    .then((VizRoot vp) {
      if(html) {
        return _printHtml(vp);
      } else {
        print(vp.toDot());
      }
    });
}

Future _printHtml(VizRoot root) {
  var templateFile = new File(_templatePath);
  assert(templateFile.existsSync());

  return templateFile.readAsString()
      .then((String content) {
        var dot = root.toDot(escapeLabels: true);

        content = content.replaceAll(DOT_PLACE_HOLDER, dot);
        content = content.replaceAll(TITLE_PLACE_HOLDER, root.root.name);

        print(content);
      });
}

String _getPath(List<String> args) {

  if(args.isEmpty) {
    return pathos.current;
  }

  if(args.length != 1) {
    print("should only have one arg -> a path");
    exit(1);
  }

  return args[0];
}

ArgParser _getParser() =>
    new ArgParser()
      ..addFlag('html', abbr: 'h', defaultsTo: false);

String get _templatePath {
  var templatePath = pathos.fromUri(Platform.script);
  templatePath = pathos.dirname(templatePath);
  templatePath = pathos.join(templatePath, '..', TEMPLATE_PATH);
  templatePath = pathos.normalize(templatePath);
  return templatePath;
}

const TEMPLATE_PATH = 'asset/pubviz.html';
const DOT_PLACE_HOLDER = 'DOT_HERE';
const TITLE_PLACE_HOLDER = 'PACKAGE_TITLE';

