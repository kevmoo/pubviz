import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as parse;
import 'package:pubviz/src/executable.dart';
import 'package:pubviz/src/root_builder.dart';

import '../test/mock_data_service.dart';

const _outdatedJsonPath = 'test/demo_workspace/outdated.json';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'skip-pub',
      abbr: 's',
      help:
          'Skip running `pub` commands in a temp project and use existing '
          'mocks.',
      negatable: false,
    );

  final args = parser.parse(arguments);
  final skipPub = args['skip-pub'] as bool;

  if (!skipPub) {
    await _resolveWorkspaceDependencies();
  }

  await _generateVizData();
}

Future<void> _resolveWorkspaceDependencies() async {
  final memberDirs = ['pkg_a', 'pkg_b', 'pkg_c'];
  final combinedDeps = _gatherConstraints(memberDirs);

  final tempDir = Directory.systemTemp.createTempSync('pubviz_temp_');
  try {
    await _runPubGet(tempDir, combinedDeps);
  } finally {
    print('Cleaning up temp project...');
    tempDir.deleteSync(recursive: true);
  }
}

Map<String, VersionConstraint> _gatherConstraints(List<String> memberDirs) {
  final combinedDeps = <String, VersionConstraint>{};

  void addDeps(Map<String, parse.Dependency> yaml) {
    for (final entry in yaml.entries) {
      final name = entry.key;
      if (name == 'outdated_pkg' || memberDirs.contains(name)) {
        continue; // Skip fake package and workspace members
      }
      final constraint = entry.value;
      final constraintString = (constraint is parse.HostedDependency)
          ? constraint.version.toString()
          : constraint.toString();

      final vc = VersionConstraint.parse(constraintString);

      if (combinedDeps.containsKey(name)) {
        final existing = combinedDeps[name]!;
        final intersection = existing.intersect(vc);
        if (intersection.isEmpty &&
            vc != VersionConstraint.any &&
            existing != VersionConstraint.any) {
          throw StateError(
            'Conflicting constraints for $name: $existing vs $vc',
          );
        }
        combinedDeps[name] = intersection;
      } else {
        combinedDeps[name] = vc;
      }
    }
  }

  for (final dir in memberDirs) {
    final pubspecFile = File(
      p.join('test/demo_workspace', dir, 'pubspec.yaml'),
    );
    if (!pubspecFile.existsSync()) continue;

    final pubspec = parse.Pubspec.parse(pubspecFile.readAsStringSync());
    addDeps(pubspec.dependencies);
    addDeps(pubspec.devDependencies);
  }

  // Ensure 'test' is included
  if (!combinedDeps.containsKey('test')) {
    combinedDeps['test'] = VersionConstraint.any;
  }

  return combinedDeps;
}

Future<void> _runPubGet(
  Directory tempDir,
  Map<String, VersionConstraint> combinedDeps,
) async {
  final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));

  print('Creating temp project in ${tempDir.path}...');

  final depsBuffer = StringBuffer();
  for (final entry in combinedDeps.entries) {
    depsBuffer.writeln('  ${entry.key}: "${entry.value}"');
  }

  pubspecFile.writeAsStringSync('''
name: temp_project
environment:
  sdk: '^3.13.0'
dependencies:
${depsBuffer.toString()}
''');

  print('Running `dart pub get` in temp project...');
  final getResult = await Process.run(Platform.resolvedExecutable, [
    'pub',
    'get',
  ], workingDirectory: tempDir.path);

  if (getResult.exitCode != 0) {
    throw ProcessException(
      Platform.resolvedExecutable,
      ['pub', 'get'],
      getResult.stderr as String,
      getResult.exitCode,
    );
  }

  _updateDemoWorkspaceDartTool(tempDir);
  await _updateOutdatedJson(tempDir);
}

void _updateDemoWorkspaceDartTool(Directory tempDir) {
  final tempGraphFile = File(
    p.join(tempDir.path, '.dart_tool', 'package_graph.json'),
  );
  final tempConfigFile = File(
    p.join(tempDir.path, '.dart_tool', 'package_config.json'),
  );

  final tempGraphJson =
      jsonDecode(tempGraphFile.readAsStringSync()) as Map<String, dynamic>;
  final tempConfigJson =
      jsonDecode(tempConfigFile.readAsStringSync()) as Map<String, dynamic>;

  const demoDir = 'test/demo_workspace';
  final dartToolDir = p.join(demoDir, '.dart_tool');
  Directory(dartToolDir).createSync(recursive: true);

  final packages =
      (tempGraphJson['packages'] as List).cast<Map<String, dynamic>>()
        ..removeWhere((p) => p['name'] == 'temp_project');

  // Insert workspace member packages
  final workspacePackages = [
    {
      'name': 'demo_workspace',
      'version': '0.0.0',
      'dependencies': <String>[],
      'devDependencies': ['dart_flutter_team_lints'],
    },
    {
      'name': 'pkg_a',
      'version': '0.0.0',
      'dependencies': ['args', 'http_parser', 'typed_data'],
      'devDependencies': ['test'],
    },
    {
      'name': 'pkg_b',
      'version': '0.0.0',
      'dependencies': ['http_parser', 'outdated_pkg', 'pkg_a'],
      'devDependencies': ['test'],
    },
    {
      'name': 'pkg_c',
      'version': '0.0.0',
      'dependencies': ['args'],
      'devDependencies': <String>[],
    },
    {'name': 'outdated_pkg', 'version': '1.0.0', 'dependencies': <String>[]},
  ];

  final allPackages = [...workspacePackages, ...packages];
  final newGraphJson = {
    'roots': ['demo_workspace', 'pkg_a', 'pkg_b', 'pkg_c'],
    'packages': allPackages,
    'configVersion': 1,
  };

  final configPackages =
      (tempConfigJson['packages'] as List).cast<Map<String, dynamic>>()
        ..removeWhere((p) => p['name'] == 'temp_project');

  final workspaceConfigPackages = [
    {
      'name': 'demo_workspace',
      'rootUri': '../',
      'packageUri': 'lib/',
      'languageVersion': '3.10',
    },
    {
      'name': 'pkg_a',
      'rootUri': '../pkg_a',
      'packageUri': 'lib/',
      'languageVersion': '3.10',
    },
    {
      'name': 'pkg_b',
      'rootUri': '../pkg_b',
      'packageUri': 'lib/',
      'languageVersion': '3.10',
    },
    {
      'name': 'pkg_c',
      'rootUri': '../pkg_c',
      'packageUri': 'lib/',
      'languageVersion': '3.10',
    },
    {
      'name': 'outdated_pkg',
      'rootUri': '../packages/outdated_pkg',
      'packageUri': 'lib/',
      'languageVersion': '3.10',
    },
  ];

  final newConfigJson = {
    'configVersion': 2,
    'packages': [...workspaceConfigPackages, ...configPackages],
    'generator': 'pub',
    'generatorVersion': '3.11.0',
  };

  const encoder = JsonEncoder.withIndent('  ');
  File(p.join(dartToolDir, 'package_graph.json'))
      .writeAsStringSync('${encoder.convert(newGraphJson)}\n');
  File(p.join(dartToolDir, 'package_config.json'))
      .writeAsStringSync('${encoder.convert(newConfigJson)}\n');
  print('Successfully updated $dartToolDir with package graph and config!');
}

Future<void> _updateOutdatedJson(Directory tempDir) async {
  print('Running `dart pub outdated` in temp project...');
  final outdatedResult = await Process.run(Platform.resolvedExecutable, [
    'pub',
    'outdated',
    '--json',
  ], workingDirectory: tempDir.path);

  if (outdatedResult.exitCode == 0) {
    final outdatedJson =
        jsonDecode(outdatedResult.stdout as String) as Map<String, dynamic>;
    final packages = outdatedJson['packages'] as List;

    final outputPackages = <Map<String, dynamic>>[
      const {
        'package': 'outdated_pkg',
        'current': {'version': '1.0.0'},
        'upgradable': {'version': '1.0.0'},
        'resolvable': {'version': '1.0.0'},
        'latest': {'version': '2.0.0'},
      },
    ];

    for (final pkg in packages.cast<Map<String, dynamic>>()) {
      final name = pkg['package'] as String;
      if (name == 'outdated_pkg') continue;
      outputPackages.add(pkg);
    }

    final outputJson = {'packages': outputPackages};
    const encoder = JsonEncoder.withIndent('  ');
    File(_outdatedJsonPath)
        .writeAsStringSync('${encoder.convert(outputJson)}\n');
    print('Successfully updated $_outdatedJsonPath!');
  } else {
    stderr.writeln('Warning: Failed to run pub outdated in temp project.');
  }
}

Future<void> _generateVizData() async {
  print('Generating VizRoot for demo workspace...');
  final service = MockDataService('test/demo_workspace');

  final vp = await service.vizRoot(includeWorkspace: true, flagOutdated: true);

  final jsContent = vizDataString(vp);

  File('web/viz_data.js').writeAsStringSync(jsContent);

  print('Successfully updated web/viz_data.js with fresh pubviz graph bits!');
}
