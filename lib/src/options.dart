import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

ArgParser get parser => _$parserForOptions;

@CliOptions()
class Options {
  @CliOption(
      abbr: 'f',
      defaultsTo: FormatOptions.html,
      allowedHelp: _formatOptionsHelp,
      valueHelp: 'format')
  final FormatOptions format;

  @CliOption(
      abbr: 'i',
      help: 'A comma seperated list of packages to exclude in the output.')
  final List<String> ignorePackages;

  @CliOption(
      abbr: 'o',
      help:
          'Check pub.dev for lasted packages and flag those that are outdated.')
  final bool flagOutdated;

  @CliOption(
      abbr: 'd',
      defaultsTo: false,
      help: 'Include only direct dependencies.',
      negatable: false)
  final bool directDependencies;

  @CliOption(abbr: '?', help: 'Print this help content.', negatable: false)
  final bool help;

  final ArgResults command;

  const Options(
      {this.format,
      this.ignorePackages,
      this.flagOutdated,
      this.directDependencies,
      this.help,
      this.command});
}

enum FormatOptions { dot, html }

const _formatOptionsHelp = <FormatOptions, String>{
  FormatOptions.dot: 'Generate a GraphViz dot file',
  FormatOptions.html:
      'Wrap the GraphViz dot format in an HTML template which renders it.'
};
