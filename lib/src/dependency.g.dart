// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'dependency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dependency _$DependencyFromJson(Map<String, dynamic> json) => Dependency(
  json['name'] as String,
  _versionConstraintFromJson(json['versionConstraint'] as String),
  json['isDevDependency'] as bool,
);

Map<String, dynamic> _$DependencyToJson(Dependency instance) =>
    <String, dynamic>{
      'name': instance.name,
      'versionConstraint': _versionConstraintToJson(instance.versionConstraint),
      'isDevDependency': instance.isDevDependency,
    };
