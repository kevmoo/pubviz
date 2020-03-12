import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'service.dart';
import 'version.dart';

class PubDataService extends Service {
  final bool _debug;

  PubDataService({bool debug = false}) : _debug = debug ?? false;

  final _client = http.Client();

  void close() => _client.close();

  @override
  Map<String, dynamic> listPackageDirs(String directory) {
    try {
      return _listPackageDirs(directory, false);
    } on ProcessException catch (e) {
      if (e.message.startsWith('Flutter is not available.') ||
          e.message.startsWith('The Flutter SDK is not available.')) {
        return _listPackageDirs(directory, true);
      } else {
        rethrow;
      }
    }
  }

  Map<String, dynamic> _listPackageDirs(String path, bool withFlutter) {
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

    return jsonDecode(result.stdout as String) as Map<String, dynamic>;
  }

  @override
  Future<List<String>> queryVersions(String packageName) async {
    final body = await _retryGet('https://pub.dev/packages/$packageName.json');

    final json = jsonDecode(body);

    assert(json['name'] == packageName);

    return (json['versions'] as List).cast<String>();
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
