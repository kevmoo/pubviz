#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:pubviz/pubviz.dart';

void main() {

  final path = _getPath();

  VizRoot.forDirectory(path)
    .then((VizRoot vp) {
      print(vp.toDot());
    });
}

String _getPath() {
  var args = (new Options()).arguments;

  if(args.isEmpty) {
    return pathos.current;
  }

  if(args.length != 1) {
    print("should only have one arg -> a path");
    exit(1);
  }

  return args[0];
}
