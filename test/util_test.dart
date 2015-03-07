import 'package:unittest/unittest.dart';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/util.dart';

void main() {
  test('existing package', () async {
    var version = await getLatestVersion('http_base');

    expect(version, new Version(0, 0, 2));
  });

  test('non-existing package', () async {
    var version = await getLatestVersion('package_no_here');

    expect(version, isNull);
  });
}
