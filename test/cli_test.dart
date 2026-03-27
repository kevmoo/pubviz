import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubviz/src/util.dart';
import 'package:pubviz/src/version.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

final _entryPoint = p.join('bin', 'pubviz.dart');

void main() {
  test('help', () async {
    final proc = await TestProcess.start(dartPath, [_entryPoint, '--help']);

    final output = await proc.stdoutStream().join('\n');
    expect(output, _usage);

    await proc.shouldExit(0);
  });

  test('version', () async {
    final proc = await TestProcess.start(dartPath, [_entryPoint, '--version']);

    final output = await proc.stdoutStream().join('\n');
    expect(output, packageVersion);

    await proc.shouldExit(0);
  });

  test('bad flag', () async {
    final proc = await TestProcess.start(dartPath, [_entryPoint, '--bob']);

    final output = await proc.stdoutStream().join('\n');
    expect(output, '''Could not find an option named "--bob".

$_usage''');

    await proc.shouldExit(64);
  });

  test('too many args', () async {
    final proc = await TestProcess.start(dartPath, [_entryPoint, 'a', 'b']);

    final output = await proc.stderrStream().join('\n');
    expect(output, 'Only one argument is allowed. You provided 2.');

    await proc.shouldExit(1);
  });

  test('print dot', () async {
    final process = await TestProcess.start(dartPath, [
      _entryPoint,
      '-a',
      'print',
    ]);

    await expectLater(process.stdout, emits('digraph pubviz {'));

    await process.shouldExit(0);
  });

  test('print dot with outdated', () async {
    final process = await TestProcess.start(dartPath, [
      _entryPoint,
      '-o',
      '-a',
      'print',
    ]);

    await expectLater(process.stdout, emits('digraph pubviz {'));

    await process.shouldExit(0);
  });

  test('serve action deletes temp dir when q is pressed', () async {
    final process = await TestProcess.start(dartPath, [
      _entryPoint,
      '-a',
      'serve',
    ]);

    late String generatedFilePath;
    await expectLater(
      process.stdout,
      emitsThrough(
        predicate<String>((line) {
          if (line.startsWith('File generated: ')) {
            generatedFilePath = line
                .substring('File generated: '.length)
                .trim();
          }
          return line.contains('Press "q"');
        }),
      ),
    );

    final targetDir = File(generatedFilePath).parent;
    expect(targetDir.existsSync(), isTrue);

    process.stdin.writeln('q');

    await expectLater(
      process.stdout,
      emitsThrough('Deleted temp directory: ${targetDir.path}'),
    );

    await process.shouldExit(0);
    expect(targetDir.existsSync(), isFalse);
  });

  test('serve action does not delete provided out-dir', () async {
    final tempDir = Directory.systemTemp.createTempSync('pubviz_test_out_');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final process = await TestProcess.start(dartPath, [
      _entryPoint,
      '-a',
      'serve',
      '--out-dir',
      tempDir.path,
    ]);

    late String generatedFilePath;
    await expectLater(
      process.stdout,
      emitsThrough(
        predicate<String>((line) {
          if (line.startsWith('File generated: ')) {
            generatedFilePath = line
                .substring('File generated: '.length)
                .trim();
          }
          return line.contains('Press "q"');
        }),
      ),
    );

    final targetDir = File(generatedFilePath).parent;
    expect(targetDir.path, equals(tempDir.path));

    process.stdin.writeln('q');

    await process.shouldExit(0);
    expect(tempDir.existsSync(), isTrue);
  });

  test('create action does not delete temp dir', () async {
    final process = await TestProcess.start(dartPath, [
      _entryPoint,
      '-a',
      'create',
    ]);

    late String generatedFilePath;
    await expectLater(
      process.stdout,
      emitsThrough(
        predicate<String>((line) {
          if (line.startsWith('File generated: ')) {
            generatedFilePath = line
                .substring('File generated: '.length)
                .trim();
            return true;
          }
          return false;
        }),
      ),
    );

    await process.shouldExit(0);

    final targetDir = File(generatedFilePath).parent;
    expect(targetDir.existsSync(), isTrue);

    // clean up after the test
    targetDir.deleteSync(recursive: true);
  });

  test('readme', () {
    final readmeContent = File('README.md').readAsStringSync();

    expect(
      readmeContent,
      contains(['```console', r'$ pubviz -?', _usage, '```'].join('\n')),
    );
  });
}

const _usage = r'''Usage: pubviz [<args>] [<package path>]

Arguments:
  -a, --action=<action>
            [create]               Generate the HTML web app in a directory.
            [open] (default)       Like "serve" but also opens the browser.
            [print]                Print the raw DOT output to stdout.
            [serve]                Like "create" but also hosts the app on a local server.

  -i, --ignore-packages            A comma separated list of packages to exclude in the output.
  -o, --[no-]flag-outdated         Check pub.dev for latest packages and flag those that are outdated.
      --out-dir                    A directory to write the generated HTML file and its localized assets. (HTML format only)
  -d, --direct-dependencies        Include only direct dependencies.
  -p, --production-dependencies    Include only production (non-dev) dependencies.
  -v, --version                    Print the version of pubviz and exit.
  -w, --[no-]workspace             Include all packages in the workspace.
  -?, --help                       Print this help content.

If <package path> is omitted, the current directory is used.''';
