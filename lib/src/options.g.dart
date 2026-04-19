// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_bool_literals_in_conditional_expressions, lines_longer_than_80_chars

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
  directDependencies: result['direct-dependencies'] as bool?,
  package: result['package'] as String?,
  productionDependencies: result['production-dependencies'] as bool,
  help: result['help'] as bool,
  rest: result.rest,
  version: result['version'] as bool,
  workspace: result['workspace'] as bool?,
  filters: result['filters'] as List<String>,
);

const _$ActionEnumMapBuildCli = <Action, String>{
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
    allowed: ['open', 'print', 'serve'],
    allowedHelp: <String, String>{
      'open': 'Like "serve" but also opens the browser.',
      'print': 'Print the raw DOT output to stdout.',
      'serve': 'Hosts the web app on a local server.',
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
    help: 'Check pub.dev for latest packages and flag those that are outdated.',
    defaultsTo: true,
  )
  ..addFlag(
    'direct-dependencies',
    abbr: 'd',
    help: 'Include only direct dependencies.',
    defaultsTo: null,
    negatable: false,
  )
  ..addOption(
    'package',
    help:
        'A published package name (and optional version) to visualize.\nI.E. "--package pubviz" or "--package pubviz:5.0.0"',
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
    defaultsTo: null,
  )
  ..addMultiOption(
    'filters',
    abbr: 'f',
    help: 'A comma separated list of filters to apply.',
    allowed: ['hide-dev', 'workspace', 'outdated', 'hide-isolated'],
    allowedHelp: <String, String>{
      'hide-dev': 'Hide dev dependencies.',
      'workspace': 'Show only packages in the workspace.',
      'outdated': 'Show only outdated packages.',
      'hide-isolated': 'Hide isolated workspace packages.',
    },
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
