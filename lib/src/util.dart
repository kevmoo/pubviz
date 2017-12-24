import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

Future<Version> getLatestVersion(String packageName) async {
  http.Response response;

  var retries = 0;
  while (true) {
    var path = 'https://pub.dartlang.org/packages/$packageName.json';
    try {
      final sdkVersion = Platform.version.split(' ').first;
      // TODO(kevmoo): use http_retry
      response = await http.get(path,
          headers: {HttpHeaders.USER_AGENT: 'pubviz - Dart $sdkVersion'});
      break;
    } catch (e) {
      stderr.writeln(e);

      retries++;
      if (retries > 3) {
        rethrow;
      } else {
        stderr.writeln('Retrying `$path`.');
      }
    }
  }

  if (response.statusCode != 200) {
    return null;
  }

  var json = JSON.decode(response.body);

  assert(json['name'] == packageName);

  var versions = (json['versions'] as List<String>)
      .map((str) => new Version.parse(str))
      .toList();

  var primary = Version.primary(versions);

  return primary;
}
