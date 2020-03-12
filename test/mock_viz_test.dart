import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/service.dart';
import 'package:test/test.dart';

import 'mock_data_service.dart';

final _mockPath = p.join('test', 'mock');

void main() {
  group('generate VizRoot', () {
    Service service;

    setUpAll(() {
      service = MockDataService(_mockPath);
    });

    test('all dependencies', () async {
      final vp = await VizRoot.forDirectory(service, _mockPath);

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(90));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(27),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        hasLength(63),
        reason: 'Only non-primary',
      );
    });

    test('direct dependencies only', () async {
      final vp = await VizRoot.forDirectory(
        service,
        _mockPath,
        directDependencies: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(22));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(22),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        isEmpty,
        reason: 'Only non-primary',
      );
    });

    test('outdated', () async {
      final vp = await VizRoot.forDirectory(
        service,
        _mockPath,
        directDependencies: true,
        flagOutdated: true,
      );

      expect(vp.root.name, 'repo_manager');
      expect(vp.root.sdkConstraint, VersionConstraint.parse('>=2.6.0 <3.0.0'));
      expect(vp.packages, hasLength(22));

      expect(
        vp.packages.values.where((element) => element.isPrimary),
        hasLength(22),
        reason: 'Only primary',
      );
      expect(
        vp.packages.values.where((element) => !element.isPrimary),
        isEmpty,
        reason: 'Only non-primary',
      );
    });
  });
}
