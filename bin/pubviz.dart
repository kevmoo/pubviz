import 'dart:io';
import 'package:pubviz/pubviz.dart';

void main() {
  var args = (new Options()).arguments;

  if(args.length != 1) {
    print("should only have one arg -> a path");
    exit(1);
    return;
  }

  final path = args[0];

  VizRoot.forDirectory(path)
    .then((VizRoot vp) {
      print(vp.toDot());
    });
}
