import 'dart:io';

void main() async {
  print('Running pubviz to generate dot graph...');
  final result = await Process.run('dart', [
    'bin/pubviz.dart',
    'print',
    '-f',
    'dot',
  ]);

  if (result.exitCode != 0) {
    stderr
      ..writeln('Failed to generate graph:')
      ..writeln(result.stderr);
    exit(1);
  }

  final dotOutput = result.stdout as String;

  final indexHtmlFile = File('_example_src/index.html');
  if (!indexHtmlFile.existsSync()) {
    stderr.writeln('Could not find _example_src/index.html');
    exit(1);
  }

  var htmlContent = indexHtmlFile.readAsStringSync();

  // Replace the contents inside the script tag using regex
  final regex = RegExp(
    r'(<script type="text/vnd\.graphviz" id="dot">)(.*?)(</script>)',
    dotAll: true,
  );

  if (!regex.hasMatch(htmlContent)) {
    stderr.writeln(
      'Could not find the target script tag in index.html to update.',
    );
    exit(1);
  }

  htmlContent = htmlContent.replaceFirstMapped(
    regex,
    (match) => '${match.group(1)}\n$dotOutput      ${match.group(3)}',
  );

  indexHtmlFile.writeAsStringSync(htmlContent);
  print(
    'Successfully updated _example_src/index.html with fresh pubviz graph bits!',
  );
}
