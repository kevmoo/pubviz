// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

T _$enumValueHelper<T>(Map<T, String> enumValues, String source) {
  if (source == null) {
    return null;
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

Options _$parseOptionsResult(ArgResults result) => Options(
    format:
        _$enumValueHelper(_$FormatOptionsEnumMap, result['format'] as String),
    ignorePackages: result['ignore-packages'] as List<String>,
    flagOutdated: result['flag-outdated'] as bool,
    help: result['help'] as bool,
    command: result.command);

const _$FormatOptionsEnumMap = <FormatOptions, String>{
  FormatOptions.dot: 'dot',
  FormatOptions.html: 'html'
};

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
          'Check pub.dev for lasted packages and flag those that are outdated.')
  ..addFlag('help',
      abbr: '?', help: 'Print this help content.', negatable: false);

final _$parserForOptions = _$populateOptionsParser(ArgParser());

Options parseOptions(List<String> args) {
  final result = _$parserForOptions.parse(args);
  return _$parseOptionsResult(result);
}
