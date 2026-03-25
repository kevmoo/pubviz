import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

final class FalseNullConverter implements JsonConverter<bool, bool?> {
  const FalseNullConverter();

  @override
  bool fromJson(bool? json) => json ?? false;

  @override
  bool? toJson(bool object) => object ? true : null;
}

final class VersionConverter implements JsonConverter<Version?, String?> {
  const VersionConverter();

  @override
  Version? fromJson(String? json) => json == null ? null : Version.parse(json);

  @override
  String? toJson(Version? version) => version?.toString();
}

final class VersionConstraintConverter
    implements JsonConverter<VersionConstraint, String> {
  const VersionConstraintConverter();

  @override
  VersionConstraint fromJson(String json) {
    try {
      return VersionConstraint.parse(json);
    } on FormatException {
      return VersionConstraint.empty;
    }
  }

  @override
  String toJson(VersionConstraint constraint) => constraint.toString();
}
