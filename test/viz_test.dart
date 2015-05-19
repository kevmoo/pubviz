import 'dart:async';
import 'dart:io';

import 'package:pubviz/pubviz.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Directory _tempDir;

void main() {
  setUp(() async {
    await _initTest();
  });

  tearDown(() async {
    await _tempDir.delete(recursive: true);
    _tempDir = null;
  });

  test('validate pub completed', () async {
    var type =
        await FileSystemEntity.type(p.join(_tempDir.path, 'pubspec.lock'));

    expect(type, FileSystemEntityType.FILE);
  });

  test('generate VizRoot', () async {
    VizRoot vp = await VizRoot.forDirectory(_tempDir.path);

    expect(vp.root.name, 'test_pubspec');
    expect(vp.packages, contains('http'));
    expect(vp.packages, contains('test'));
  });
}

Future _initTest() async {
  assert(_tempDir == null);
  _tempDir = await Directory.systemTemp.createTemp('pubviz.test.');

  // add pubspec
  var content =
      await new File(p.join('test', 'test_pubspec.yaml')).readAsString();

  await new File(p.join(_tempDir.path, 'pubspec.yaml')).writeAsString(content);

  // NOTE: since all dependencies in the the sample pubspec are in pubviz
  //       we can use offline to improve speed.
  ProcessResult pr = await Process.run('pub', ['get', '--offline'],
      workingDirectory: _tempDir.path);

  if (pr.exitCode != 0) {
    fail([pr.stdout, pr.stderr].join('\n'));
  }
}
