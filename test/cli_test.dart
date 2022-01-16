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
    expect(
      output,
      '''Could not find an option named "bob".

$_usage''',
    );

    await proc.shouldExit(64);
  });

  test('no command', () async {
    final proc = await TestProcess.start(dartPath, [_entryPoint]);

    final output = await proc.stdoutStream().join('\n');
    expect(
      output,
      '''Specify a command: open, print

$_usage''',
    );

    await proc.shouldExit(64);
  });

  test('print dot', () async {
    final process = await TestProcess.start(
      dartPath,
      [_entryPoint, '-f', 'dot', 'print'],
    );

    await expectLater(process.stdout, emits('digraph pubviz {'));

    await process.shouldExit(0);
  });

  test('print dot with outdated', () async {
    final process = await TestProcess.start(
      dartPath,
      [_entryPoint, '-o', '-f', 'dot', 'print'],
    );

    await expectLater(process.stdout, emits('digraph pubviz {'));

    await process.shouldExit(0);
  });

  test('readme', () {
    final readmeContent = File('README.md').readAsStringSync();

    expect(
      readmeContent,
      contains(['```console', r'$ pubviz -?', _usage, '```'].join('\n')),
    );
  });
}

const _usage = r'''Usage: pubviz [<args>] <command> [<package path>]

Commands:
  open   Populate a temporary file with the content and open it.
  print  Print the output to stdout.

Arguments:
  -f, --format=<format>
            [dot]                  Generate a GraphViz dot file
            [html] (default)       Wrap the GraphViz dot format in an HTML template which renders it.

  -i, --ignore-packages            A comma separated list of packages to exclude in the output.
  -o, --[no-]flag-outdated         Check pub.dev for lasted packages and flag those that are outdated.
  -d, --direct-dependencies        Include only direct dependencies.
  -p, --production-dependencies    Include only production (non-dev) dependencies.
  -v, --version                    Print the version of pubviz and exit.
  -?, --help                       Print this help content.

If <package path> is omitted, the current directory is used.''';
