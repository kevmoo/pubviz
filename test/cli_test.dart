import 'dart:io';

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  test('help', () async {
    final proc = await TestProcess.start('dart', ['bin/pubviz.dart', '--help']);

    final output = await proc.stdoutStream().join('\n');
    expect(output, _usage);

    await proc.shouldExit(0);
  });

  test('bad flag', () async {
    final proc = await TestProcess.start('dart', ['bin/pubviz.dart', '--bob']);

    final output = await proc.stdoutStream().join('\n');
    expect(output, '''Could not find an option named "bob".

$_usage''');

    await proc.shouldExit(64);
  });

  test('no command', () async {
    final proc = await TestProcess.start('dart', ['bin/pubviz.dart']);

    final output = await proc.stdoutStream().join('\n');
    expect(output, '''Specify a command: open, print

$_usage''');

    await proc.shouldExit(64);
  });

  test('readme', () {
    final readmeContent = File('README.md').readAsStringSync();

    expect(readmeContent,
        contains(['```console', r'$ pubviz -?', _usage, '```'].join('\n')));
  });
}

const _usage = r'''Usage: pubviz [<args>] <command> [<package path>]

Commands:
  open   Populate a temporary file with the content and open it.
  print  Print the output to stdout.

Arguments:
  -f, --format=<format>
            [dot]               Generate a GraphViz dot file
            [html] (default)    Wrap the GraphViz dot format in an HTML template which renders it.

  -i, --ignore-packages         A comma seperated list of packages to exclude in the output.
  -o, --[no-]flag-outdated      Check pub.dartlang.org for lasted packages and flag those that are outdated.
  -?, --help                    Print this help content.

If <package path> is omitted, the current directory is used.''';
