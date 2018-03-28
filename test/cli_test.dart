import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  test('help', () async {
    var proc = await TestProcess.start('dart', ['bin/pubviz.dart', '--help']);

    var output = await proc.stdoutStream().join('\n');
    expect(output,
        r'''Usage: pubviz [--format=<format>] [--ignore-packages=<package1>,<package2>] (open | print) [<package path>]

  open   Populate a temporary file with the content and open it.
  print  Print the output to stdout.

-f, --format                
          [dot]             Generate a GraphViz dot file
          [html]            Wrap the GraphViz dot format in an HTML template which renders it.

-i, --ignore-packages       A comma seperated list of packages to exclude in the output.
-o, --[no-]flag-outdated    Check pub.dartlang.org for lasted packages and flag those that are outdated.
-h, --[no-]help             Print this help content.

If <package path> is omitted, the current directory is used.''');

    await proc.shouldExit(0);
  });
}
