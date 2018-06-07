import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

final _hedears = {
  HttpHeaders.USER_AGENT: 'pubviz - Dart ${Platform.version.split(' ').first}'
};

Future<Version> getLatestVersion(
    String packageName, bool includePreRelease) async {
  http.Response response;

  var retries = 0;
  while (true) {
    var path = 'https://pub.dartlang.org/packages/$packageName.json';
    try {
      // TODO(kevmoo): use http_retry
      response = await http.get(path, headers: _hedears);
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

  var json = jsonDecode(response.body);

  assert(json['name'] == packageName);

  var versions = (json['versions'] as List<String>)
      .map((str) => new Version.parse(str))
      .toList();

  var primary = latestVersion(versions, includePreRelease);

  return primary;
}

Version latestVersion(List<Version> versions, bool includePreRelease) {
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
