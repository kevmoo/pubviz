import 'dart:convert';
import 'dart:io';

import 'package:pubviz/src/root_builder.dart';

import '../test/mock_data_service.dart';

void main() async {
  print('Generating VizRoot for demo workspace...');
  final service = MockDataService('test/demo_workspace');

  final vp = await service.vizRoot(includeWorkspace: true, flagOutdated: true);

  const encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(vp.toJson());
  // We need vizDataString to be a raw JavaScript string representing JSON.
  final jsContent =
      'export const vizDataString = JSON.stringify($jsonString);\n';

  File('_example_src/viz_data.js').writeAsStringSync(jsContent);

  print(
    'Successfully updated _example_src/viz_data.js with fresh pubviz graph bits!',
  );
}
