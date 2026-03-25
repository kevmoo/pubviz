// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'viz_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VizPackage _$VizPackageFromJson(Map<String, dynamic> json) => VizPackage(
  json['name'] as String,
  _versionFromJson(json['version'] as String?),
  (json['dependencies'] as List<dynamic>)
      .map((e) => Dependency.fromJson(e as Map<String, dynamic>))
      .toSet(),
  _versionFromJson(json['latestVersion'] as String?),
  isPrimary: json['isPrimary'] as bool? ?? false,
)..onlyDev = json['onlyDev'] as bool? ?? true;

Map<String, dynamic> _$VizPackageToJson(VizPackage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': _versionToJson(instance.version),
      'dependencies': instance.dependencies.toList(),
      'isPrimary': instance.isPrimary,
      'onlyDev': instance.onlyDev,
      'latestVersion': _versionToJson(instance.latestVersion),
    };
