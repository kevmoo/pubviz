import 'dart:convert' show LineSplitter;
import 'dart:js_interop';

import 'package:web/web.dart';

import '../colors.dart';
import '../dot.dart';

import 'interop.dart';
import 'pubviz_app.dart';

final class GraphRenderer {
  final PubvizApp _app;
  VizInstance? _vizInstance;
  SVGElement? __root;
  SVGGElement? _lockedElement;
  final _nodeOutdatedMap = <String, bool>{};

  GraphRenderer(this._app);

  SVGElement get _root => __root!;

  void updateZoom() {
    if (_app.ui.zoomEnabled) {
      __root?.classList.add('zoom');
    } else {
      __root?.classList.remove('zoom');
    }
  }

  Future<void> render() async {
    if (__root != null) {
      _root.remove();
      __root = null;
      _lockedElement = null;
    }

    final watch = Stopwatch()..start();
    try {
      _vizInstance ??= await Viz.instance().toDart;

      final filteredRoot = _app.originalVizRoot.filter(
        excludeDev: _app.ui.hideDevDependencies,
        onlyOutdated: _app.ui.outdatedOnly,
        onlyWorkspace: _app.ui.workspaceOnly,
      );

      final dotString = filteredRoot.toDot();

      final output = _vizInstance!.renderString(
        dotString,
        RenderOptions(format: 'svg'),
      );
      _updateBody(output);
    } catch (e, stack) {
      try {
        _app.ui.showCrashReport(e.toString(), stack.toString());
      } catch (error, stack) {
        console.error(
          '''Even the crash reporter crashed!,
          $error,
          $stack,
        '''
              .toJS,
        );
      }
      rethrow;
    } finally {
      console.info('Total time generating graph: ${watch.elapsed}'.toJS);
    }
  }

  void _updateBody(String output) {
    assert(__root == null);

    output = LineSplitter.split(output)
        .where(
          (line) =>
              !line.contains('<!--') &&
              !line.contains('-->') &&
              !line.contains('?xml'),
        )
        .join('\n');

    document
        .querySelector('#graph-container')!
        .insertAdjacentHTML('beforeend', output.toJS);

    __root = document.querySelector('svg') as SVGElement;
    if (_app.ui.zoomEnabled) {
      __root!.classList.add('zoom');
    }

    _nodeOutdatedMap.clear();
    final nodes = _root.querySelectorAll('g.node').elements.map((e) {
      final element = e as SVGGElement;
      final title = element.querySelector('title')!.textContent!;
      element.id = title;

      final nodeStroke =
          element.querySelector('ellipse')?.getAttribute('stroke') ??
          element.querySelector('polygon')?.getAttribute('stroke') ??
          element.querySelector('path')?.getAttribute('stroke');

      final isOutdated = isOutdatedColor(nodeStroke);
      if (isOutdated) {
        element.classList.add('outdated');
      }
      _nodeOutdatedMap[title] = isOutdated;

      return (element: element, id: title);
    }).toList();

    final edges = _root.querySelectorAll('g.edge').elements.map((e) {
      final node = e as SVGGElement;
      final title = node.querySelector('title')!.textContent!;
      final things = title.split('->');
      final from = things[0];
      final to = things[1];
      node
        ..setAttribute('x-from', from)
        ..setAttribute('x-to', to);

      final textElement = node.querySelector('text');
      final textFill = textElement?.getAttribute('fill');
      final constraint = textElement?.textContent ?? '';
      final edgeStroke =
          node.getAttribute('stroke') ??
          node.querySelector('path')?.getAttribute('stroke') ??
          node.querySelector('polygon')?.getAttribute('stroke');

      final isDev =
          node.querySelector('path')?.hasAttribute('stroke-dasharray') ?? false;

      if (isOutdatedColor(textFill) || isOutdatedColor(edgeStroke)) {
        node.classList.add('outdated');
      }
      return (
        element: node,
        from: from,
        to: to,
        constraint: constraint,
        isDev: isDev,
      );
    }).toList();

    _root.onMouseOver.listen((MouseEvent event) {
      final target =
          (event.target as Element).closest('g.node, g.edge') as SVGGElement?;
      final related =
          (event.relatedTarget as Element?)?.closest('g.node, g.edge')
              as SVGGElement?;

      if (target == related) return;

      if (target != null) {
        final textElements = target.querySelectorAll('text');
        final text = textElements.elements
            .map((e) => e.textContent?.trim() ?? '')
            .where((t) => t.isNotEmpty)
            .join(' ');
        if (text.isNotEmpty) {
          _app.ui.showToast(text);
        }
      }

      if (_lockedElement == null) {
        _updateOver(target, nodes, edges);
      }
    });

    _root.onMouseLeave.listen((_) {
      if (_lockedElement == null) {
        _updateOver(null, nodes, edges);
      }
    });

    _root.onClick.listen((MouseEvent event) {
      final target =
          (event.target as Element).closest('g.node, g.edge') as SVGGElement?;
      if (target != null) {
        if (_lockedElement == target) {
          _lockedElement = null;
        } else {
          _lockedElement = target;
        }
        _updateOver(_lockedElement ?? target, nodes, edges);
      } else if (_lockedElement != null) {
        _lockedElement = null;
        _updateOver(null, nodes, edges);
      }
    });
  }

  void _updateOver(
    SVGGElement? element,
    Iterable<({SVGGElement element, String id})> nodes,
    Iterable<
      ({
        SVGGElement element,
        String from,
        String to,
        String constraint,
        bool isDev,
      })
    >
    edges,
  ) {
    final targetPkg = <String?>[];
    if (element != null) {
      if (element.classList.contains('edge')) {
        targetPkg.addAll([
          element.attributes['x-to'],
          element.attributes['x-from'],
        ]);
      } else {
        assert(element.classList.contains('node'));
        targetPkg.add(element.id);
      }
    }

    for (var node in nodes) {
      if (targetPkg.contains(node.id)) {
        node.element.classList.add('active');
      } else {
        node.element.classList.remove('active');
      }

      if (node.element == _lockedElement) {
        node.element.classList.add('locked');
      } else {
        node.element.classList.remove('locked');
      }
    }

    final fromDeps = <DepInfo>[];
    final toDeps = <DepInfo>[];
    for (var edge in edges) {
      final nodeXTo = edge.to;
      final nodeXFrom = edge.from;
      if (targetPkg.length == 2) {
        if (targetPkg.contains(nodeXTo) && targetPkg.contains(nodeXFrom)) {
          edge.element.classList.add('active');
        } else {
          edge.element.classList.remove('active');
        }
      } else {
        if (targetPkg.contains(nodeXTo) || targetPkg.contains(nodeXFrom)) {
          if (targetPkg.contains(nodeXTo)) {
            fromDeps.add((
              name: nodeXFrom,
              constraint: edge.constraint,
              isDev: edge.isDev,
              isNodeOutdated: _nodeOutdatedMap[nodeXFrom] ?? false,
              isEdgeOutdated: edge.element.classList.contains('outdated'),
            ));
          }

          if (targetPkg.contains(nodeXFrom)) {
            toDeps.add((
              name: nodeXTo,
              constraint: edge.constraint,
              isDev: edge.isDev,
              isNodeOutdated: _nodeOutdatedMap[nodeXTo] ?? false,
              isEdgeOutdated: edge.element.classList.contains('outdated'),
            ));
          }

          edge.element.classList.add('active');
        } else {
          edge.element.classList.remove('active');
        }
      }

      if (edge.element == _lockedElement) {
        edge.element.classList.add('locked');
      } else {
        edge.element.classList.remove('locked');
      }
    }

    if (targetPkg.length == 1) {
      _app.ui.updateBoxes(fromDeps: fromDeps, toDeps: toDeps);
    } else {
      _app.ui.updateBoxes(fromDeps: [], toDeps: []);
    }
  }
}
