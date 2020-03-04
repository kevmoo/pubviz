import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

abstract class Service {
  Pubspec pubspecForDirectory(String directory);

  Map<String, String> packageMap(
    String path,
    bool withFlutter,
    bool directDependencies,
  );

  Future<Version> queryLatestVersion(
    String packageName,
    bool includePreRelease,
  );
}
