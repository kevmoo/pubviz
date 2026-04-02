import 'dart:convert' show LineSplitter, htmlEscape;
import 'dart:js_interop';

import 'package:pubviz/src/colors.dart';
import 'package:pubviz/src/dot.dart';

import 'package:web/web.dart';

import 'interop.dart';
import 'pubviz_app.dart';

typedef DepInfo = ({
  String name,
  String constraint,
  bool isDev,
  bool isNodeOutdated,
  bool isEdgeOutdated,
});

final class GraphRenderer {
  final PubvizApp app;
  VizInstance? _vizInstance;
  SVGElement? __root;
  SVGGElement? _lockedElement;

  GraphRenderer(this.app);

  SVGElement get _root => __root!;

  void toggleZoomStyle() {
    __root?.classList.toggle('zoom');
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

      final filteredRoot = app.originalVizRoot.filter(
        excludeDev: !app.ui.devDependenciesCheckbox.checked,
        onlyOutdated: app.ui.outdatedOnlyCheckbox.checked,
      );

      final dotString = filteredRoot.toDot();

      final output = _vizInstance!.renderString(
        dotString,
        RenderOptions(format: 'svg'),
      );
      _updateBody(output);
    } catch (e) {
      final output = '<pre>${htmlEscape.convert(e.toString())}</pre>';
      document.querySelector('#graph-container')!.append(output.toJS);
      rethrow;
    } finally {
      print('Total time generating graph: ${watch.elapsed}');
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
    if (app.ui.zoomCheckbox.checked) {
      __root!.classList.add('zoom');
    }

    final nodes = _root.querySelectorAll('g.node').elements.map((e) {
      final element = e as SVGGElement;
      final title = element.querySelector('title')!.textContent!;
      element.id = title;

      final nodeStroke =
          element.querySelector('ellipse')?.getAttribute('stroke') ??
          element.querySelector('polygon')?.getAttribute('stroke') ??
          element.querySelector('path')?.getAttribute('stroke');

      if (isOutdatedColor(nodeStroke)) {
        element.classList.add('outdated');
      }

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

    void handleMouseEnter(MouseEvent event) {
      if (_lockedElement == null) {
        _updateOver(event.currentTarget as SVGGElement, nodes, edges);
      }
    }

    void handleMouseLeave(MouseEvent event) {
      if (_lockedElement == null) {
        _updateOver(null, nodes, edges);
      }
    }

    void handleClick(MouseEvent event) {
      event.stopPropagation();
      final target = event.currentTarget as SVGGElement;
      if (_lockedElement == target) {
        _lockedElement = null;
      } else {
        _lockedElement = target;
      }
      _updateOver(_lockedElement ?? target, nodes, edges);
    }

    for (var entry in nodes) {
      entry.element.onMouseEnter.listen(handleMouseEnter);
      entry.element.onMouseLeave.listen(handleMouseLeave);
      entry.element.onClick.listen(handleClick);
    }

    for (var entry in edges) {
      entry.element.onMouseEnter.listen(handleMouseEnter);
      entry.element.onMouseLeave.listen(handleMouseLeave);
      entry.element.onClick.listen(handleClick);
    }

    _root.onClick.listen((MouseEvent event) {
      if (_lockedElement != null) {
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

    final nodeOutdatedMap = {
      for (var node in nodes)
        node.id: node.element.classList.contains('outdated'),
    };

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
              isNodeOutdated: nodeOutdatedMap[nodeXFrom] ?? false,
              isEdgeOutdated: edge.element.classList.contains('outdated'),
            ));
          }

          if (targetPkg.contains(nodeXFrom)) {
            toDeps.add((
              name: nodeXTo,
              constraint: edge.constraint,
              isDev: edge.isDev,
              isNodeOutdated: nodeOutdatedMap[nodeXTo] ?? false,
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
      fromDeps.sort((a, b) => a.name.compareTo(b.name));
      toDeps.sort((a, b) => a.name.compareTo(b.name));

      String buildTable(Iterable<DepInfo> deps) {
        final rows = deps.map((d) {
          final nameHtml = htmlEscape.convert(d.name);
          var nameCell = d.isDev ? '<i>$nameHtml</i>' : nameHtml;
          if (d.isNodeOutdated) {
            nameCell = '<span class="outdated-node">$nameCell</span>';
          }

          var constraintCell = htmlEscape.convert(d.constraint);
          if (d.isEdgeOutdated) {
            constraintCell =
                '<span class="outdated-edge">$constraintCell</span>';
          }

          return '<tr><td>$nameCell</td><td>$constraintCell</td></tr>';
        }).join();
        return '<table class="deps-table"><thead><tr><th>Name</th><th>Constraint</th></tr></thead><tbody>$rows</tbody></table>';
      }

      void updateHudBox(HTMLDivElement box, String title, List<DepInfo> deps) {
        if (deps.isNotEmpty) {
          box.style.display = 'flex';
          box.innerHTML =
              '<h3>$title</h3><div class="table-scroll">${buildTable(deps)}</div>'
                  .toJS;
        } else {
          box.style.display = 'none';
        }
      }

      updateHudBox(app.ui.depsInBox, 'INCOMING', fromDeps);
      updateHudBox(app.ui.depsOutBox, 'OUTGOING', toDeps);
    } else {
      app.ui.depsInBox.style.display = 'none';
      app.ui.depsOutBox.style.display = 'none';
    }
  }
}
