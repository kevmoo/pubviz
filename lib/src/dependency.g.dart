// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_bool_literals_in_conditional_expressions, lines_longer_than_80_chars

part of 'dependency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dependency _$DependencyFromJson(Map<String, dynamic> json) => Dependency(
  json['name'] as String,
  const VersionConstraintConverter().fromJson(
    json['versionConstraint'] as String,
  ),
  const FalseNullConverter().fromJson(json['isDevDependency'] as bool?),
  includesLatest: json['includesLatest'] as bool?,
);

Map<String, dynamic> _$DependencyToJson(Dependency instance) =>
    <String, dynamic>{
      'name': instance.name,
      'versionConstraint': const VersionConstraintConverter().toJson(
        instance.versionConstraint,
      ),
      'isDevDependency': ?const FalseNullConverter().toJson(
        instance.isDevDependency,
      ),
      'includesLatest': ?instance.includesLatest,
    };
