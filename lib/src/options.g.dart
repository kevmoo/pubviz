// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

Options _$parseOptionsResult(ArgResults result) {
  T enumValueHelper<T>(String enumName, List<T> values, String enumValue) =>
      enumValue == null
          ? null
          : values.singleWhere((e) => e.toString() == '$enumName.$enumValue',
              orElse: () => throw new StateError(
                  'Could not find the value `$enumValue` in enum `$enumName`.'));

  return new Options(
      format: enumValueHelper(
          'FormatOptions', FormatOptions.values, result['format'] as String),
      ignorePackages: result['ignore-packages'] as List<String>,
      flagOutdated: result['flag-outdated'] as bool,
      help: result['help'] as bool,
      command: result.command);
}

ArgParser _$populateOptionsParser(ArgParser parser) => parser
  ..addOption('format',
      abbr: 'f',
      valueHelp: 'format',
      defaultsTo: 'html',
      allowed: [
        'dot',
        'html'
      ],
      allowedHelp: <String, String>{
        'dot': 'Generate a GraphViz dot file',
        'html':
            'Wrap the GraphViz dot format in an HTML template which renders it.'
      })
  ..addMultiOption('ignore-packages',
      abbr: 'i',
      help: 'A comma seperated list of packages to exclude in the output.')
  ..addFlag('flag-outdated',
      abbr: 'o',
      help:
          'Check pub.dartlang.org for lasted packages and flag those that are outdated.')
  ..addFlag('help',
      abbr: '?', help: 'Print this help content.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(new ArgParser());

Options parseOptions(List<String> args) {
  var result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
