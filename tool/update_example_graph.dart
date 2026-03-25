import 'dart:convert';
import 'dart:io';

import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/root_builder.dart';

void main() async {
  print('Generating VizRoot for current workspace...');
  final service = PubDataService(Directory.current.path);

  final vp = await service.vizRoot(flagOutdated: true);

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
