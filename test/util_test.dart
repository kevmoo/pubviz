import 'package:test/test.dart';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/util.dart';

void main() {
  test('existing package', () async {
    var version = await getLatestVersion('bot');

    expect(version, new Version(0, 28, 0));
  });

  test('non-existing package', () async {
    var version = await getLatestVersion('package_no_here');

    expect(version, isNull);
  });
}
