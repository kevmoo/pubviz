@TestOn('vm')
library;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pubviz/src/executable.dart';
import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/version.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

final _entryPoint = p.join('bin', 'pubviz.dart');

void main() {
  test('help', () async {
    final proc = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '--help',
    ]);

    final output = await proc.stdoutStream().join('\n');
    expect(output, _usage);

    await proc.shouldExit(0);
  });

  test('version', () async {
    final proc = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '--version',
    ]);

    final output = await proc.stdoutStream().join('\n');
    expect(output, packageVersion);

    await proc.shouldExit(0);
  });

  test('bad flag', () async {
    final proc = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '--bob',
    ]);

    final output = await proc.stdoutStream().join('\n');
    expect(output, '''Could not find an option named "--bob".

$_usage''');

    await proc.shouldExit(64);
  });

  test('bad filter', () async {
    final proc = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '-a',
      'print',
      '--filters',
      'bob',
    ]);

    final output = await proc.stdoutStream().join('\n');
    expect(
      output,
      contains('"bob" is not an allowed value for option "--filters".'),
    );

    await proc.shouldExit(64);
  });

  test('print with filter hide-dev', () async {
    final process = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '-a',
      'print',
      '--filters',
      'hide-dev',
    ]);

    final output = await process.stdoutStream().join('\n');
    expect(output, contains('digraph pubviz {'));
    expect(output, isNot(contains('"test" [')));

    await process.shouldExit(0);
  });

  test('too many args', () async {
    final proc = await TestProcess.start(Platform.executable, [
      _entryPoint,
      'a',
      'b',
    ]);

    final output = await proc.stdoutStream().join('\n');
    expect(output, '''Only one argument is allowed. You provided 2.

$_usage''');

    await proc.shouldExit(64);
  });

  test('print dot', () async {
    final process = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '-a',
      'print',
    ]);

    await expectLater(process.stdout, emits('digraph pubviz {'));

    await process.shouldExit(0);
  });

  test('print dot with outdated', () async {
    final process = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '-o',
      '-a',
      'print',
    ]);

    await expectLater(process.stdout, emits('digraph pubviz {'));

    await process.shouldExit(0);
  });

  test('serve action stops when q is pressed', () async {
    final process = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '-a',
      'serve',
    ]);

    await expectLater(process.stdout, emitsThrough(contains('Press "q"')));

    process.stdin.writeln('q');

    await process.shouldExit(0);
  });

  test('serve action serves viz_data.js', () async {
    final process = await TestProcess.start(Platform.executable, [
      _entryPoint,
      '-a',
      'serve',
    ]);

    late String serverUrl;
    await expectLater(
      process.stdout,
      emitsThrough(
        predicate<String>((line) {
          if (line.startsWith('Serving pubviz on ')) {
            serverUrl = line.substring('Serving pubviz on '.length).trim();
            return true;
          }
          return false;
        }),
      ),
    );

    final response = await http.get(Uri.parse('${serverUrl}viz_data.js'));
    expect(response.statusCode, equals(200));
    expect(response.headers['content-type'], contains('text/javascript'));
    expect(response.body, contains('vizDataString'));

    process.stdin.writeln('q');
    await process.shouldExit(0);
  });

  group('workspace inference', () {
    setUp(() async {
      await d.dir('workspace', [
        d.file('pubspec.yaml', '''
name: root
environment:
  sdk: ^3.10.0
workspace:
  - pkga
'''),
        d.dir('pkga', [
          d.file('pubspec.yaml', '''
name: pkga
environment:
  sdk: ^3.10.0
resolution: workspace
'''),
        ]),
      ]).create();

      final getProcess = await TestProcess.start(Platform.executable, [
        'pub',
        'get',
        '--offline',
      ], workingDirectory: d.path('workspace'));
      await getProcess.shouldExit(0);
    });

    test('implicitly includes all packages when in workspace root', () async {
      final process = await TestProcess.start(Platform.executable, [
        _entryPoint,
        '-a',
        'print',
        d.path('workspace'),
      ]);

      final output = await process.stdoutStream().join('\n');

      // Both packages should be present as highlighted primary nodes.
      // Since root was the invocation target, it gets the primary label
      // format without a version.
      expect(output, contains('root [label="⚙️ root"'));
      expect(output, contains(r'pkga [label="pkga\n0.0.0"'));

      await process.shouldExit(0);
    });

    test(
      'implicitly includes all packages when run from a workspace member',
      () async {
        final process = await TestProcess.start(Platform.executable, [
          _entryPoint,
          '-a',
          'print',
          d.path('workspace/pkga'),
        ]);

        final output = await process.stdoutStream().join('\n');

        // Both packages should be present as highlighted primary nodes.
        expect(output, contains(r'root [label="root\n0.0.0"'));
        expect(output, contains('pkga [label="⚙️ pkga"'));

        await process.shouldExit(0);
      },
    );

    test('--no-workspace disables implicit inclusion', () async {
      final process = await TestProcess.start(Platform.executable, [
        _entryPoint,
        '-a',
        'print',
        '--no-workspace',
        d.path('workspace'),
      ]);

      final output = await process.stdoutStream().join('\n');

      // Only root should be present. 'pkga' should not be heavily highlighted
      // or included at all because the root package does not list it as a
      // dependency.
      expect(output, contains('root [label=root'));
      expect(output, isNot(contains('pkga')));

      await process.shouldExit(0);
    });
  });

  test('integration test with published package:pubviz', () async {
    const options = Options(
      action: Action.print,
      flagOutdated: false,
      productionDependencies: false,
      help: false,
      rest: [],
      version: false,
      package: 'pubviz:6.0.0',
    );

    expect(
      () => run(options),
      prints(
        allOf(
          contains('digraph pubviz'),
          contains('pubviz -\u003e args'),
          contains('pubviz -\u003e path'),
        ),
      ),
    );
  });

  test('integration test with published package:analyzer', () async {
    const options = Options(
      action: Action.print,
      flagOutdated: false,
      productionDependencies: false,
      help: false,
      rest: [],
      version: false,
      package: 'analyzer',
    );

    expect(
      () => run(options),
      prints(allOf(contains('digraph pubviz'), contains('analyzer [label='))),
    );
  });

  test('readme', () {
    final readmeContent = File('README.md').readAsStringSync();

    expect(
      readmeContent,
      contains(['```console', r'$ pubviz -?', _usage, '```'].join('\n')),
    );
  });
}

const _usage = r'''Usage: pubviz [<args>] [<package path>]

Arguments:
  -a, --action=<action>
            [open] (default)       Like "serve" but also opens the browser.
            [print]                Print the raw DOT output to stdout.
            [serve]                Hosts the web app on a local server.

  -i, --ignore-packages            A comma separated list of packages to exclude in the output.
  -o, --[no-]flag-outdated         Check pub.dev for latest packages and flag those that are outdated.
                                   (defaults to on)
  -d, --direct-dependencies        Include only direct dependencies.
      --package                    A published package name (and optional version) to visualize.
                                   I.E. "--package pubviz" or "--package pubviz:5.0.0"
  -p, --production-dependencies    Include only production (non-dev) dependencies.
  -v, --version                    Print the version of pubviz and exit.
  -w, --[no-]workspace             Include all packages in the workspace.
  -f, --filters                    A comma separated list of filters to apply.

            [hide-dev]             Hide dev dependencies.
            [workspace]            Show only packages in the workspace.
            [outdated]             Show only outdated packages.

  -?, --help                       Print this help content.

If <package path> is omitted, the current directory is used.''';
