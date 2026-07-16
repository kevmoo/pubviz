@Tags(['presubmit'])
library;

import 'package:collection/collection.dart';
import 'package:pubviz/src/assets.g.dart';
import 'package:test/scaffolding.dart';

import '../tool/shared.dart';

void main() {
  test('ensure web assets are built and up-to-date', () async {
    final currentInputs = await hashInputs();
    if (!const MapEquality<String, String>().equals(
      currentInputs,
      assetInputs,
    )) {
      final allKeys = {...currentInputs.keys, ...assetInputs.keys};
      final changedFiles =
          allKeys.where((k) => currentInputs[k] != assetInputs[k]).toList()
            ..sort();
      final errorMessage = StringBuffer(
        'Input files have changed since the last assets build.\n',
      );
      if (changedFiles.isNotEmpty) {
        errorMessage.writeln(
          'Files changed:\n'
          '${changedFiles.map((f) => '  - $f').join('\n')}\n',
        );
      }
      throw StateError(
        '$errorMessage'
        'Please run `dart tool/update_assets.dart` and commit the updated files.',
      );
    }
  });
}
