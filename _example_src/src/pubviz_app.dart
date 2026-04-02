import 'dart:convert' show jsonDecode;
import 'dart:js_interop';

import 'package:pubviz/src/viz_root.dart';
import 'package:web/web.dart';

import 'graph_renderer.dart';
import 'ui_manager.dart';

final class PubvizApp {
  late final UIManager ui;
  late final GraphRenderer renderer;
  late final VizRoot originalVizRoot;
  late final bool hasOutdated;

  PubvizApp(JSString vizDataJson) {
    final jsonString = vizDataJson.toDart.trim();
    originalVizRoot = VizRoot.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    document.title = 'pubviz - ${originalVizRoot.root.name}';

    hasOutdated = originalVizRoot.packages.values.any(
      (p) =>
          p.version != null &&
          p.latestVersion != null &&
          p.latestVersion!.compareTo(p.version!) > 0,
    );

    ui = UIManager(this);
    renderer = GraphRenderer(this);
  }

  Future<void> run() async {
    await renderer.render();
  }
}
