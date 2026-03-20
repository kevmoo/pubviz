// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) => enumValues
    .entries
    .singleWhere(
      (e) => e.value == source,
      orElse: () => throw ArgumentError(
        '`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}',
      ),
    )
    .key;

Options _$parseOptionsResult(ArgResults result) => Options(
  action: _$enumValueHelper(
    _$ActionEnumMapBuildCli,
    result['action'] as String,
  ),
  ignorePackages: result['ignore-packages'] as List<String>,
  flagOutdated: result['flag-outdated'] as bool,
  outDir: result['out-dir'] as String?,
  directDependencies: result['direct-dependencies'] as bool?,
  productionDependencies: result['production-dependencies'] as bool,
  help: result['help'] as bool,
  rest: result.rest,
  version: result['version'] as bool,
  workspace: result['workspace'] as bool,
);

const _$ActionEnumMapBuildCli = <Action, String>{
  Action.create: 'create',
  Action.open: 'open',
  Action.print: 'print',
  Action.serve: 'serve',
};

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption(
    'action',
    abbr: 'a',
    valueHelp: 'action',
    defaultsTo: 'open',
    allowed: ['create', 'open', 'print', 'serve'],
    allowedHelp: <String, String>{
      'create': 'Generate the HTML web app in a directory.',
      'open': 'Like "serve" but also opens the browser.',
      'print': 'Print the raw DOT output to stdout.',
      'serve': 'Like "create" but also hosts the app on a local server.',
    },
  )
  ..addMultiOption(
    'ignore-packages',
    abbr: 'i',
    help: 'A comma separated list of packages to exclude in the output.',
  )
  ..addFlag(
    'flag-outdated',
    abbr: 'o',
    help: 'Check pub.dev for lasted packages and flag those that are outdated.',
  )
  ..addOption(
    'out-dir',
    help:
        'A directory to write the generated HTML file and its localized assets. (HTML format only)',
  )
  ..addFlag(
    'direct-dependencies',
    abbr: 'd',
    help: 'Include only direct dependencies.',
    defaultsTo: null,
    negatable: false,
  )
  ..addFlag(
    'production-dependencies',
    abbr: 'p',
    help: 'Include only production (non-dev) dependencies.',
    negatable: false,
  )
  ..addFlag(
    'version',
    abbr: 'v',
    help: 'Print the version of pubviz and exit.',
    negatable: false,
  )
  ..addFlag(
    'workspace',
    abbr: 'w',
    help: 'Include all packages in the workspace.',
    negatable: false,
  )
  ..addFlag(
    'help',
    abbr: '?',
    help: 'Print this help content.',
    negatable: false,
  );

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
