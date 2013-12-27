#pubviz
## Visualize package dependencies in your Dart project

1. Make sure you run `pub install` or `pub update` in your target project directory.
1. Run `pubviz` passing in the target project directory as the only argument
    * `./bin/pubviz.dart ~/pubviz/`
1. Notice the pretty output:

```
digraph G {

  path [label="path
0.6.5",shape=box,margin="0.25,0.15",group=primary];

  pubviz [label="pubviz
0.1.0-dev",fontsize=16,style=bold,shape=box,margin="0.25,0.15",group=primary];
  pubviz -> path [label=">=0.6.5",fontcolor=gray,penwidth=2];
  pubviz -> unmodifiable_collection [label=">=0.6.5",fontcolor=gray,penwidth=2];
  pubviz -> yaml [label=">=0.6.5",fontcolor=gray,penwidth=2];

  unmodifiable_collection [label="unmodifiable_collection
0.6.5",shape=box,margin="0.25,0.15",group=primary];

  yaml [label="yaml
0.6.5",shape=box,margin="0.25,0.15",group=primary];
}
```

Direct the ouput to a `dot` file: `./bin/pubviz.dart ~/some_dart_project/ > some_dot_file.dot` and use [GraphViz](http://www.graphviz.org/) to generate a PNG.

![sample](https://raw.github.com/kevmoo/pubviz/master/doc/sample.png)
