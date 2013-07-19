#pubviz
## Visualize package dependencies in your Dart project

1. Make sure you run `pub install` or `pub update` in your target project directory.
1. Run `pubviz` passing in the target project directory as the only argument
    * `./bin/pubviz.dart ~/source/github/pubviz/`
1. Notice the pretty output:

```
digraph G {

  path [label="path
0.6.5",shape=box]

  pubviz [label="pubviz
",shape=box]
  pubviz -> path [label=">=0.6.5",fontcolor=gray]
  pubviz -> unmodifiable_collection [label=">=0.6.5",fontcolor=gray]
  pubviz -> yaml [label=">=0.6.5",fontcolor=gray]

  unmodifiable_collection [label="unmodifiable_collection
0.6.5",shape=box]

  yaml [label="yaml
0.6.5",shape=box]
}
```

Direct the ouput to a `dot` file: `./bin/pubviz.dart ~/some_dart_project/ > some_dot_file.dot` and use [GraphViz](http://www.graphviz.org/) to generate a PNG.

![sample](https://raw.github.com/kevmoo/pubviz/master/docs/sample.png)
