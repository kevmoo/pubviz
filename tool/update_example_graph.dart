import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as parse;
import 'package:pubviz/src/executable.dart';
import 'package:pubviz/src/root_builder.dart';

import '../test/mock_data_service.dart';

const _pubDepsListPath = 'test/demo_workspace/pub_deps_list.json';
const _outdatedJsonPath = 'test/demo_workspace/outdated.json';
const _workspaceListPath = 'test/demo_workspace/workspace_list.json';

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
  final memberDirs = _findWorkspaceMembers();
  final combinedDeps = _gatherConstraints(memberDirs);

  final tempDir = Directory.systemTemp.createTempSync('pubviz_temp_');
  try {
    await _runPubGetAndDeps(tempDir, combinedDeps);
  } finally {
    print('Cleaning up temp project...');
    tempDir.deleteSync(recursive: true);
  }
}

List<String> _findWorkspaceMembers() {
  final workspaceListFile = File(_workspaceListPath);
  if (workspaceListFile.existsSync()) {
    final json = jsonDecode(
      workspaceListFile.readAsStringSync(),
    ) as Map<String, dynamic>;
    final packages = json['packages'] as List;
    return packages
        .cast<Map<String, dynamic>>()
        .map((p) => p['path'] as String)
        .toList();
  }
  return ['pkg_a', 'pkg_b'];
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
    if (dir == '.') continue;
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

Future<void> _runPubGetAndDeps(
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
  final getResult = await Process.run(Platform.executable, [
    'pub',
    'get',
  ], workingDirectory: tempDir.path);

  if (getResult.exitCode != 0) {
    throw ProcessException(
      Platform.executable,
      ['pub', 'get'],
      getResult.stderr as String,
      getResult.exitCode,
    );
  }

  print('Running `dart pub deps --json` in temp project...');
  final depsResult = await Process.run(Platform.executable, [
    'pub',
    'deps',
    '--json',
  ], workingDirectory: tempDir.path);

  if (depsResult.exitCode != 0) {
    throw ProcessException(
      Platform.executable,
      ['pub', 'deps'],
      depsResult.stderr as String,
      depsResult.exitCode,
    );
  }

  _updatePubDepsList(depsResult.stdout as String);
  await _updateOutdatedJson(tempDir);
}

void _updatePubDepsList(String depsOutput) {
  final decoded = jsonDecode(depsOutput) as Map<String, dynamic>;
  final existingFile = File(_pubDepsListPath);
  if (!existingFile.existsSync()) {
    throw const FileSystemException('File not found', _pubDepsListPath);
  }

  final existingJson =
      jsonDecode(existingFile.readAsStringSync()) as Map<String, dynamic>;
  final existingPackages = (existingJson['packages'] as List)
      .cast<Map<String, dynamic>>();

  final rootPackages = existingPackages
      .where((p) => p['kind'] == 'root')
      .toList();

  final tempPackages = (decoded['packages'] as List)
      .cast<Map<String, dynamic>>();

  final nonRootPackages = tempPackages
      .where((p) => p['kind'] != 'root')
      .toList();

  final merged = {
    'root': existingJson['root'] ?? 'demo_workspace',
    'packages': [...rootPackages, ...nonRootPackages],
    'sdks': decoded['sdks'] ?? existingJson['sdks'],
    'executables':
        decoded['executables'] ?? existingJson['executables'] ?? <Object>[],
  };

  const encoder = JsonEncoder.withIndent('  ');
  existingFile.writeAsStringSync('${encoder.convert(merged)}\n');
  print('Successfully updated $_pubDepsListPath!');
}

Future<void> _updateOutdatedJson(Directory tempDir) async {
  print('Running `dart pub outdated` in temp project...');
  final outdatedResult = await Process.run(Platform.executable, [
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
