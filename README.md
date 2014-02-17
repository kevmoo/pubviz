#pubviz
### Visualize package dependencies in your Dart project

*Make sure you run `pub get` or `pub upgrade` in your target project directory.*

### Generate and open an html file for a package.

```
dart bin/pubviz.dart open /path/to/http_package
```

Should open your default browser to something like:

![sample](https://raw.github.com/kevmoo/pubviz/master/doc/sample.png)


### Print GraphViz dot format to command line

```
dart bin/pubviz.dart --format=dot print /path/to/http_package
```

You should see output something like:

```
digraph G {
  node [fontname=Helvetica];
  edge [fontname=Helvetica, fontcolor=gray];

  http [label="http
0.9.2+3",fontsize=18,style=bold,shape=box,margin="0.25,0.15"];
  http -> path [label=">=0.9.0 <2.0.0",penwidth=2];
  http -> stack_trace [label=">=0.9.1 <0.10.0",penwidth=2];
  http -> unittest [label=">=0.9.0 <0.10.0",penwidth=2,style=dashed];

  path [label="path
1.0.0",shape=box,margin="0.25,0.15",style=bold];

  stack_trace [label="stack_trace
0.9.1",shape=box,margin="0.25,0.15",style=bold];
  stack_trace -> path [label=">=1.0.0-rc.1 <2.0.0"];

  unittest [label="unittest
0.9.3",style=bold];
  unittest -> stack_trace [label=">=0.9.0 <0.10.0",color=gray];
}
```

### pubviz with no arguments prints help

```
usage: pubviz [--format=<format>] (open | print) [<package path>]

  open   Populate a temporary file with the content and open it.
  print  Print the output to stdout.

-f, --format
          [dot]     Generate a GraphViz dot file
          [html]    Wrap the GraphViz dot format in an HTML template which renders it.

If <package path> is omitted, the current directory is used.
```
