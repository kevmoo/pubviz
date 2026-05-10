import 'dart:io';

void main() async {
  print('Generating Mermaid diagram for pubviz (production only)...');
  final result = await Process.run(Platform.executable, [
    'bin/pubviz.dart',
    '-a',
    'print-mermaid',
    '-p',
  ]);

  if (result.exitCode != 0) {
    stderr
      ..writeln('Failed to generate Mermaid diagram:')
      ..writeln(result.stderr);
    exit(result.exitCode);
  }

  final mermaidDiagram = (result.stdout as String).trim();
  final readmeFile = File('README.md');
  if (!readmeFile.existsSync()) {
    stderr.writeln('README.md not found.');
    exit(1);
  }

  var content = readmeFile.readAsStringSync();

  const startMarker = '<!-- MERMAID_START -->';
  const endMarker = '<!-- MERMAID_END -->';

  final newSnippet =
      '''
$startMarker
```mermaid
$mermaidDiagram
```
$endMarker''';

  if (content.contains(startMarker) && content.contains(endMarker)) {
    print('Updating existing Mermaid block in README.md...');
    final startIndex = content.indexOf(startMarker);
    final endIndex = content.indexOf(endMarker) + endMarker.length;
    content = content.replaceRange(startIndex, endIndex, newSnippet);
  } else {
    print('Replacing raw raw.github.com png link in README.md...');
    const targetImage =
        '![sample](https://raw.github.com/kevmoo/pubviz/master/doc/sample.png)';
    if (!content.contains(targetImage)) {
      stderr.writeln('Could not find the target PNG placeholder in README.md');
      exit(1);
    }
    content = content.replaceFirst(targetImage, newSnippet);
  }

  readmeFile.writeAsStringSync(content);
  print('Successfully updated README.md with the Mermaid diagram!');
}
