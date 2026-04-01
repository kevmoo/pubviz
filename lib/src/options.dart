import 'package:build_cli_annotations/build_cli_annotations.dart';

part 'options.g.dart';

ArgParser get parser => _$parserForOptions;

@CliOptions()
class Options {
  @CliOption(
    abbr: 'a',
    defaultsTo: Action.open,
    allowedHelp: _actionHelp,
    valueHelp: 'action',
  )
  final Action action;

  @CliOption(
    abbr: 'i',
    help: 'A comma separated list of packages to exclude in the output.',
  )
  final List<String> ignorePackages;

  @CliOption(
    abbr: 'o',
    help: 'Check pub.dev for latest packages and flag those that are outdated.',
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

  @CliOption(abbr: 'w', help: 'Include all packages in the workspace.')
  final bool? workspace;

  @CliOption(abbr: '?', help: 'Print this help content.', negatable: false)
  final bool help;

  final List<String> rest;

  const Options({
    required this.action,
    List<String>? ignorePackages,
    required this.flagOutdated,
    this.directDependencies,
    required this.productionDependencies,
    required this.help,
    required this.rest,
    required this.version,
    this.workspace,
  }) : ignorePackages = ignorePackages ?? const [];
}

enum Action { open, print, serve }

const _actionHelp = <Action, String>{
  Action.open: 'Like "serve" but also opens the browser.',
  Action.print: 'Print the raw DOT output to stdout.',
  Action.serve: 'Hosts the web app on a local server.',
};
