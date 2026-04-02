import 'dart:convert' show jsonDecode;
import 'dart:js_interop';

import 'package:pubviz/src/viz_root.dart';
import 'package:web/web.dart';

import 'graph_renderer.dart';
import 'ui_manager.dart';

typedef DepInfo = ({
  String name,
  String constraint,
  bool isDev,
  bool isNodeOutdated,
  bool isEdgeOutdated,
});

final class PubvizApp {
  late final UIManager ui;
  late final GraphRenderer _renderer;
  late final VizRoot originalVizRoot;
  bool get hasOutdated => originalVizRoot.hasOutdated;

  PubvizApp(JSString vizDataJson) {
    final jsonString = vizDataJson.toDart.trim();
    originalVizRoot = VizRoot.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    document.title = 'pubviz - ${originalVizRoot.root.name}';

    ui = UIManager(this);
    _renderer = GraphRenderer(this);
  }

  Future<void> render() => _renderer.render();

  void toggleZoomStyle() => _renderer.toggleZoomStyle();

  Future<void> run() async {
    await render();
  }
}
