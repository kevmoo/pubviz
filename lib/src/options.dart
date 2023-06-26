import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

ArgParser get parser => _$parserForOptions;

@CliOptions()
class Options {
  @CliOption(
    abbr: 'f',
    defaultsTo: FormatOptions.html,
    allowedHelp: _formatOptionsHelp,
    valueHelp: 'format',
  )
  final FormatOptions format;

  @CliOption(
    abbr: 'i',
    help: 'A comma separated list of packages to exclude in the output.',
  )
  final List<String> ignorePackages;

  @CliOption(
    abbr: 'o',
    help: 'Check pub.dev for lasted packages and flag those that are outdated.',
  )
  final bool flagOutdated;

  @CliOption(
    abbr: 'd',
    help: 'Include only direct dependencies.',
    negatable: false,
  )
  final bool? directDependencies;

  @CliOption(
    abbr: 'p',
    help: 'Include only production (non-dev) dependencies.',
    negatable: false,
  )
  final bool productionDependencies;

  @CliOption(
    abbr: 'v',
    help: 'Print the version of pubviz and exit.',
    negatable: false,
  )
  final bool version;

  @CliOption(
    abbr: '?',
    help: 'Print this help content.',
    negatable: false,
  )
  final bool help;

  final ArgResults? command;

  const Options({
    required this.format,
    List<String>? ignorePackages,
    required this.flagOutdated,
    this.directDependencies,
    required this.productionDependencies,
    required this.help,
    this.command,
    required this.version,
  }) : ignorePackages = ignorePackages ?? const [];
}

enum FormatOptions { dot, html }

const _formatOptionsHelp = <FormatOptions, String>{
  FormatOptions.dot: 'Generate a GraphViz dot file',
  FormatOptions.html:
      'Wrap the GraphViz dot format in an HTML template which renders it.',
};
