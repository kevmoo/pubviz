import 'package:test/test.dart';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/util.dart';

void main() {
  test('existing package', () async {
    var version = await getLatestVersion('bot', false);

    expect(version, new Version(0, 28, 0));
  });

  test('non-existing package', () async {
    var version = await getLatestVersion('package_no_here', false);

    expect(version, isNull);
  });

  group('primary', () {
    List<Version> options;

    setUpAll(() {
      options = [
        new Version(1, 0, 0),
        new Version(1, 2, 3),
        new Version(1, 2, 3, pre: '0'),
      ];
    });

    test('without prerelease', () {
      expect(latestVersion(options, false), new Version(1, 2, 3));
    });

    test('without prerelease', () {
      expect(latestVersion(options, true), new Version(1, 2, 3));
    });
  });
}
