// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_bool_literals_in_conditional_expressions, lines_longer_than_80_chars

part of 'viz_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VizPackage _$VizPackageFromJson(Map<String, dynamic> json) => VizPackage(
  json['name'] as String,
  const VersionConverter().fromJson(json['version'] as String?),
  (json['dependencies'] as List<dynamic>)
      .map((e) => Dependency.fromJson(e as Map<String, dynamic>))
      .toSet(),
  const VersionConverter().fromJson(json['latestVersion'] as String?),
  isPrimary: json['isPrimary'] == null
      ? false
      : const FalseNullConverter().fromJson(json['isPrimary'] as bool?),
  onlyDev: json['onlyDev'] as bool? ?? true,
);

Map<String, dynamic> _$VizPackageToJson(VizPackage instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': ?const VersionConverter().toJson(instance.version),
      'dependencies': instance.dependencies.toList(),
      'isPrimary': ?const FalseNullConverter().toJson(instance.isPrimary),
      'onlyDev': ?_trueToNull(instance.onlyDev),
      'latestVersion': ?const VersionConverter().toJson(instance.latestVersion),
    };
