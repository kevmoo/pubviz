import 'package:pub_semver/pub_semver.dart';

class OutdatedInfo {
  final String package;
  final Version? current, upgradable, resolvable, latest;

  OutdatedInfo(
    this.package,
    this.current,
    this.upgradable,
    this.resolvable,
    this.latest,
  );

  factory OutdatedInfo.fromJson(Map<String, dynamic> json) => OutdatedInfo(
        json['package'] as String,
        _version(json, 'current'),
        _version(json, 'upgradable'),
        _version(json, 'resolvable'),
        _version(json, 'latest'),
      );
}

Version? _version(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;

  return Version.parse(
    (json[key] as Map<String, dynamic>)['version'] as String,
  );
}
