### Visualize package dependencies in your Dart project

[![Pub Package](https://img.shields.io/pub/v/pubviz.svg)](https://pub.dev/packages/pubviz)
[![package publisher](https://img.shields.io/pub/publisher/pubviz.svg)](https://pub.dev/packages/pubviz/publisher)
[![CI](https://github.com/kevmoo/pubviz/actions/workflows/ci.yml/badge.svg)](https://github.com/kevmoo/pubviz/actions/workflows/ci.yml)

*Make sure you run `dart pub get` or `dart pub upgrade` in your target project directory.*

### Example

Here's an [example](https://kevmoo.github.io/pubviz/) of `pubviz` run on itself.

### Installing

Activate `pubviz`.
```console
$ dart pub global activate pubviz
```

### Use

If you have [configured your PATH correctly][path], you can run `pubviz`
directly.

```console
$ pubviz
```

Otherwise, you can use the `pub global` command.

```console
$ dart pub global run pubviz
```

### Generate and open an HTML file for the package on the current path.

```console
$ pubviz
```

Will open the default browser to something like:

<!-- MERMAID_START -->
```mermaid
flowchart TD
  classDef primary fill:#e3f2fd,stroke:#0175C2,stroke-width:2px;
  classDef outdated stroke:#e53935,stroke-width:2px;
  classDef publishToNone stroke-dasharray: 5 5;
  args["args<br/>2.7.0"]
  async["async<br/>2.13.1"]
  build_cli_annotations["build_cli_annotations<br/>2.1.1"]
  checked_yaml["checked_yaml<br/>2.0.4"]
  collection["collection<br/>1.19.1"]
  convert["convert<br/>3.1.2"]
  gviz["gviz<br/>0.4.2"]
  http["http<br/>1.6.0"]
  http_parser["http_parser<br/>4.1.2"]
  io["io<br/>1.0.5"]
  json_annotation["json_annotation<br/>4.11.0"]
  meta["meta<br/>1.18.2"]
  mime["mime<br/>2.0.0"]
  path["path<br/>1.9.1"]
  pub_semver["pub_semver<br/>2.2.0"]
  pubspec_parse["pubspec_parse<br/>1.5.0"]
  pubviz["pubviz<br/>6.2.0-wip"]
  shelf["shelf<br/>1.4.2"]
  shelf_static["shelf_static<br/>1.1.3"]
  source_span["source_span<br/>1.10.2"]
  stack_trace["stack_trace<br/>1.12.1"]
  stream_channel["stream_channel<br/>2.1.4"]
  string_scanner["string_scanner<br/>1.4.1"]
  term_glyph["term_glyph<br/>1.2.2"]
  typed_data["typed_data<br/>1.4.0"]
  web["web<br/>1.1.1"]
  yaml["yaml<br/>3.1.3"]
  async -- "^1.15.0"--> collection
  async -- "^1.3.0"--> meta
  build_cli_annotations -- "^2.6.0"--> args
  build_cli_annotations -- "^1.16.0"--> meta
  checked_yaml -- "^4.3.0"--> json_annotation
  checked_yaml -- "^1.8.0"--> source_span
  checked_yaml -- "^3.0.0"--> yaml
  convert -- "^1.3.0"--> typed_data
  http -- "^2.5.0"--> async
  http -- "^4.0.0"--> http_parser
  http -- "^1.3.0"--> meta
  http -- ">=0.5.0 <2.0.0"--> web
  http_parser -- "^1.19.0"--> collection
  http_parser -- "^1.8.0"--> source_span
  http_parser -- "^1.1.0"--> string_scanner
  http_parser -- "^1.3.0"--> typed_data
  io -- "^1.3.0"--> meta
  io -- "^1.8.0"--> path
  io -- "^1.1.0"--> string_scanner
  json_annotation -- "^1.16.0"--> meta
  pub_semver -- "^1.15.0"--> collection
  pubspec_parse -- "^2.0.1"--> checked_yaml
  pubspec_parse -- "^1.19.0"--> collection
  pubspec_parse -- "^4.9.0"--> json_annotation
  pubspec_parse -- "^2.1.4"--> pub_semver
  pubspec_parse -- "^3.0.0"--> yaml
  pubviz -- "^2.6.0"--> args
  pubviz -- "^2.1.1"--> build_cli_annotations
  pubviz -- "^1.19.0"--> collection
  pubviz -- "^0.4.2"--> gviz
  pubviz -- "^1.0.0"--> http
  pubviz -- "^1.0.0"--> io
  pubviz -- "^4.11.0"--> json_annotation
  pubviz -- "^1.18.2"--> meta
  pubviz -- "^1.9.0"--> path
  pubviz -- "^2.1.4"--> pub_semver
  pubviz -- "^1.5.0"--> pubspec_parse
  pubviz -- "^1.4.1"--> shelf
  pubviz -- "^1.1.2"--> shelf_static
  pubviz -- "^1.10.0"--> stack_trace
  pubviz -- "^1.2.0"--> string_scanner
  pubviz -- "^1.0.0"--> web
  pubviz -- "^3.1.3"--> yaml
  shelf -- "^2.5.0"--> async
  shelf -- "^1.15.0"--> collection
  shelf -- "^4.1.0"--> http_parser
  shelf -- "^1.8.0"--> path
  shelf -- "^1.10.0"--> stack_trace
  shelf -- "^2.1.0"--> stream_channel
  shelf_static -- "^3.0.0"--> convert
  shelf_static -- "^4.0.0"--> http_parser
  shelf_static -- ">=1.0.0 <3.0.0"--> mime
  shelf_static -- "^1.8.0"--> path
  shelf_static -- "^1.1.2"--> shelf
  source_span -- "^1.15.0"--> collection
  source_span -- "^1.8.0"--> path
  source_span -- "^1.2.0"--> term_glyph
  stack_trace -- "^1.8.0"--> path
  stream_channel -- "^2.5.0"--> async
  string_scanner -- "^1.8.0"--> source_span
  typed_data -- "^1.15.0"--> collection
  yaml -- "^1.15.0"--> collection
  yaml -- "^1.8.0"--> source_span
  yaml -- "^1.2.0"--> string_scanner
  class pubviz primary;
```
<!-- MERMAID_END -->

### Print GraphViz dot format to command line for a package on a specified path.

```console
$ pubviz -a print /path/to/http_package
```

You should see output something like:

```dot
digraph G {
  node [fontname=Helvetica];
  edge [fontname=Helvetica, fontcolor=gray];

  http [label="http
1.2.0",fontsize=18,style=bold,shape=box,margin="0.25,0.15"];
  http -> async [label="^2.5.0",penwidth=2];
  http -> http_parser [label="^4.0.0",penwidth=2];
  http -> path [label="^1.8.0",penwidth=2];

  async [label="async
2.11.0",shape=box,margin="0.25,0.15",style=bold];
  async -> collection [label="^1.15.0"];

  collection [label="collection
1.18.0",shape=box,margin="0.25,0.15",style=bold];

  http_parser [label="http_parser
4.0.2",shape=box,margin="0.25,0.15",style=bold];
  http_parser -> collection [label="^1.15.0",color=gray];
  http_parser -> source_span [label="^1.8.0",color=gray];

  path [label="path
1.9.0",shape=box,margin="0.25,0.15",style=bold];
}
```

### Generate PDF, PNG and other files

[GraphViz](https://graphviz.org/about/) tool allows dot format to be converted to various types of outputs like PNG, PDF or SVG. 

In order to export `pubviz` data to PNG file you need to install GraphViz package on your machine ([see detailed installation instructions](https://graphviz.org/doc/info/output.html)). 

On macOS:

```sh
brew install graphviz
```

On Windows:

```sh
winget install graphviz
```

Then you can save the `pubviz` output to a file and convert it with `dot`
command to desired output type, e.g.:

```sh
pubviz -a print > output.dot
dot -Tpdf output.dot -o output.pdf
```

The full list of possible output types is available on
[the GraphViz website](https://graphviz.org/doc/info/output.html).

### `pubviz -?` prints help

```console
$ pubviz -?
Usage: pubviz [<args>] [<package path>]

Arguments:
  -a, --action=<action>
            [open] (default)       Like "serve" but also opens the browser.
            [print]                Print the raw DOT output to stdout.
            [print-mermaid]        Print the Mermaid flowchart output to stdout.
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
            [hide-isolated]        Hide isolated workspace packages.

  -?, --help                       Print this help content.

If <package path> is omitted, the current directory is used.
```

[path]: https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path
