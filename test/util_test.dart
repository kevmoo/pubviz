import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/src/util.dart';
import 'package:test/test.dart';

void main() {
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
      expect(primaryVersion(options, false), Version(1, 2, 3));
    });

    test('without prerelease', () {
      expect(primaryVersion(options, true), Version(1, 2, 3));
    });
  });
}
