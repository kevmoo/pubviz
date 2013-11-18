#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:pubviz/pubviz.dart';

void main(List<String> args) {

  final path = _getPath(args);

  VizRoot.forDirectory(path)
    .then((VizRoot vp) {
      print(vp.toDot());
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
