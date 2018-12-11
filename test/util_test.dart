import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/util.dart';
import 'package:test/test.dart';

void main() {
  test('existing package', () async {
    final version = await getLatestVersion('bot', false);

    expect(version, Version(0, 28, 0));
  });

  test('non-existing package', () async {
    final version = await getLatestVersion('package_no_here', false);

    expect(version, isNull);
  });

  group('primary', () {
    List<Version> options;

    setUpAll(() {
      options = [
        Version(1, 0, 0),
        Version(1, 2, 3),
        Version(1, 2, 3, pre: '0'),
      ];
    });

    test('without prerelease', () {
      expect(latestVersion(options, false), Version(1, 2, 3));
    });

    test('without prerelease', () {
      expect(latestVersion(options, true), Version(1, 2, 3));
    });
  });
}
