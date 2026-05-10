import 'dart:io';
import 'package:pubviz/src/mermaid.dart';
import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/root_builder.dart';

void main() async {
  print('Generating Mermaid diagram for pubviz (production only)...');

  final service = PubDataService('.');
  final vp = await service.vizRoot(
    flagOutdated: true,
    productionDependenciesOnly: true,
  );

  final mermaidDiagram = vp.toMermaid().trim();
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
    stderr.writeln('Could not find the Mermaid markers in README.md');
    exitCode = 1;
    return;
  }

  readmeFile.writeAsStringSync(content);
  print('Successfully updated README.md with the Mermaid diagram!');
}
