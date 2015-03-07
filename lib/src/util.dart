import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

Future<Version> getLatestVersion(String packageName) async {
  var response =
      await http.get("https://pub.dartlang.org/packages/$packageName.json");

  if (response.statusCode != 200) {
    return null;
  }

  var json = JSON.decode(response.body);

  assert(json['name'] == packageName);

  var versions =
      (json['versions'] as List).map((str) => new Version.parse(str)).toList();

  var primary = Version.primary(versions);

  return primary;
}
