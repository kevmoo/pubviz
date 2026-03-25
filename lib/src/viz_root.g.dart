// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'viz_root.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VizRoot _$VizRootFromJson(Map<String, dynamic> json) => VizRoot(
  json['rootPackageName'] as String,
  (json['packages'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, VizPackage.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$VizRootToJson(VizRoot instance) => <String, dynamic>{
  'rootPackageName': instance.rootPackageName,
  'packages': instance.packages,
};
