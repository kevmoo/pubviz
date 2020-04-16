import 'dart:io';

import 'package:path/path.dart' as p;
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

final String dartPath = p.join(_sdkDir, 'bin', 'dart');

final String pubPath =
    p.join(_sdkDir, 'bin', Platform.isWindows ? 'pub.bat' : 'pub');

/// The path to the root directory of the SDK.
final String _sdkDir = (() {
  // The Dart executable is in "/path/to/sdk/bin/dart", so two levels up is
  // "/path/to/sdk".
  final aboveExecutable = p.dirname(p.dirname(Platform.resolvedExecutable));
  assert(FileSystemEntity.isFileSync(p.join(aboveExecutable, 'version')));
  return aboveExecutable;
})();
