#pubviz
## Visualize package dependencies in your Dart project

1. Make sure you run `pub install` or `pub update` in your target project directory.
1. Run `pubviz` passing in the target project directory as the only argument
    * `./bin/pubviz.dart ~/pubviz/`
1. Notice the pretty output:

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

Direct the ouput to a `dot` file: `./bin/pubviz.dart ~/some_dart_project/ > some_dot_file.dot` and use [GraphViz](http://www.graphviz.org/) to generate a PNG.

![sample](https://raw.github.com/kevmoo/pubviz/master/doc/sample.png)
