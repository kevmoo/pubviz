import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'service.dart';
import 'util.dart';
import 'version.dart';

class PubDataService extends Service {
  final bool _debug;

  PubDataService({bool debug = false}) : _debug = debug ?? false;

  final _client = http.Client();

  void close() => _client.close();

  @override
  Pubspec pubspecForDirectory(String directory) {
    assert(Directory(directory).existsSync());

    final pubspecPath = p.join(directory, 'pubspec.yaml');

    _print('open pubspec: $pubspecPath');

    return Pubspec.parse(
      File(pubspecPath).readAsStringSync(),
      sourceUrl: pubspecPath,
    );
  }

  @override
  Map<String, String> packageMap(
    String path,
    bool withFlutter,
    bool directDependencies,
  ) {
    try {
      return _packageMap(path, false, directDependencies);
    } on ProcessException catch (e) {
      if (e.message.startsWith('Flutter is not available.') ||
          e.message.startsWith('The Flutter SDK is not available.')) {
        return _packageMap(path, true, directDependencies);
      } else {
        rethrow;
      }
    }
  }

  Map<String, String> _packageMap(
    String path,
    bool withFlutter,
    bool directDependencies,
  ) {
    final map = <String, String>{};

    final proc = withFlutter ? 'flutter' : 'pub';
    final args = withFlutter
        ? ['packages', 'pub', 'list-package-dirs']
        : ['list-package-dirs'];

    _print(['list-package-dirs:', proc, ...args].join(' '));
    _print('  in path `$path`');

    final result = Process.runSync(
      proc,
      args,
      runInShell: true,
      workingDirectory: path,
    );

    if (result.exitCode != 0) {
      var message = result.stderr as String;
      try {
        final value = jsonDecode(result.stdout as String) as Map;
        if (value.containsKey('error')) {
          message = value['error'] as String;
        }
      } catch (e) {
        // NOOP
      }

      throw ProcessException(
        proc,
        args,
        message,
        result.exitCode,
      );
    }

    final json = jsonDecode(result.stdout as String);
    var packageEntries = (json['packages'] as Map<String, dynamic>).entries;

    if (directDependencies) {
      final pubspec = pubspecForDirectory(path);

      packageEntries = packageEntries.where(
        (entry) =>
            pubspec.dependencies.containsKey(entry.key) ||
            entry.key == pubspec.name,
      );
    }

    for (var entry in packageEntries) {
      assert(p.basename(entry.value as String) == 'lib');
      map[entry.key] = p.dirname(entry.value as String);
    }

    return map;
  }

  @override
  Future<Version> queryLatestVersion(
    String packageName,
    bool includePreRelease,
  ) async {
    final body = await _retryGet('https://pub.dev/packages/$packageName.json');

    final json = jsonDecode(body);

    assert(json['name'] == packageName);

    final versions = (json['versions'] as List)
        .map((str) => Version.parse(str as String))
        .toList();

    final primary = primaryVersion(versions, includePreRelease);

    return primary;
  }

  Future<String> _retryGet(String path) async {
    http.Response response;

    var retries = 0;
    for (;;) {
      try {
        // TODO(kevmoo): use http_retry
        _print('requesting package json: $path');
        response = await _client.get(path, headers: _headers);
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

    return response.body;
  }

  void _print(Object value) {
    if (_debug) {
      stderr.writeln('  $value');
    }
  }
}

final _headers = {
  'user-agent': 'pubviz/$packageVersion '
      '(Dart/${Platform.version.split(' ').first}; '
      'https://pub.dev/packages/pubviz)'
};
