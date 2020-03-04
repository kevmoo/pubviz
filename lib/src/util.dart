import 'package:pub_semver/pub_semver.dart';

Version primaryVersion(List<Version> versions, bool includePreRelease) {
  if (includePreRelease) {
    Version primary;
    for (var version in versions) {
      if (primary == null || version > primary) {
        primary = version;
      }
    }
    return primary;
  }

  return Version.primary(versions);
}
