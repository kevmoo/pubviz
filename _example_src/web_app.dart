// ignore_for_file: unreachable_from_main

@JS()
library;

import 'dart:async';
import 'dart:convert' show LineSplitter, htmlEscape, jsonDecode;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:pubviz/src/colors.dart';
import 'package:pubviz/src/dot.dart';
import 'package:pubviz/src/version.dart';
import 'package:pubviz/src/viz_root.dart';
import 'package:web/web.dart';

typedef DepInfo = ({
  String name,
  String constraint,
  bool isDev,
  bool isNodeOutdated,
  bool isEdgeOutdated,
});

final hamburgerBtn =
    document.querySelector('#hamburgerBtn') as HTMLButtonElement;
final controlsPanel =
    document.querySelector('#controls-panel') as HTMLDivElement;
final zoomCheckbox =
    document.querySelector('#zoomCheckbox') as HTMLInputElement;
final devDependenciesCheckbox =
    document.querySelector('#devDependenciesCheckbox') as HTMLInputElement;
final outdatedCheckboxContainer =
    document.querySelector('#outdatedCheckboxContainer') as HTMLDivElement;
final outdatedOnlyCheckbox =
    document.querySelector('#outdatedOnlyCheckbox') as HTMLInputElement;

final depsInBox = document.querySelector('#deps-in-box') as HTMLDivElement;
final depsOutBox = document.querySelector('#deps-out-box') as HTMLDivElement;

VizInstance? _vizInstance;

SVGElement? __root;
SVGGElement? _lockedElement;

SVGElement get _root => __root!;

late final VizRoot _originalVizRoot;

void main() async {
  final url = Uri.parse(window.location.href).resolve('viz_data.js').toString();
  final module = await importModule(url.toJS).toDart;
  final string = module.getProperty('vizDataString'.toJS) as JSString?;

  if (string == null) {
    throw StateError('`vizDataString` is not defined locally or globally.');
  }

  final jsonString = string.toDart.trim();
  _originalVizRoot = VizRoot.fromJson(
    jsonDecode(jsonString) as Map<String, dynamic>,
  )..update(false);
  document.title = 'pubviz - ${_originalVizRoot.root.name}';
  final hasOutdated = _originalVizRoot.packages.values.any(
    (p) =>
        p.version != null &&
        p.latestVersion != null &&
        p.latestVersion!.compareTo(p.version!) > 0,
  );
  if (!hasOutdated) {
    outdatedOnlyCheckbox.disabled = true;
    outdatedCheckboxContainer.title = 'No outdated packages found.';
  }

  unawaited(_process());

  depsInBox.onWheel.listen((e) => e.stopPropagation());
  depsOutBox.onWheel.listen((e) => e.stopPropagation());

  void toggleControls() {
    controlsPanel.classList.toggle('collapsed');
  }

  hamburgerBtn.onClick.listen((_) {
    toggleControls();
  });

  void toggleZoom() {
    zoomCheckbox.checked = !zoomCheckbox.checked;
    __root?.classList.toggle('zoom');
  }

  zoomCheckbox.onChange.listen((_) {
    __root?.classList.toggle('zoom');
  });

  devDependenciesCheckbox.onChange.listen((_) {
    unawaited(_process());
  });

  outdatedOnlyCheckbox.onChange.listen((_) {
    unawaited(_process());
  });

  window.onKeyDown.listen((KeyboardEvent event) {
    switch (event.key) {
      case 'c' || 'C':
        toggleControls();
      case 'z' || 'Z':
        toggleZoom();
      case 'd' || 'D':
        devDependenciesCheckbox.checked = !devDependenciesCheckbox.checked;
        _process();
      case 'o' || 'O':
        if (hasOutdated) {
          outdatedOnlyCheckbox.checked = !outdatedOnlyCheckbox.checked;
          _process();
        }
    }
  });

  (document.querySelector('#version') as HTMLSpanElement).textContent =
      'v$packageVersion';
}

Future<void> _process() async {
  if (__root != null) {
    _root.remove();
    __root = null;
    _lockedElement = null;
  }

  final watch = Stopwatch()..start();
  try {
    _vizInstance ??= await Viz.instance().toDart;

    final filteredRoot = _originalVizRoot.filter(
      excludeDev: !devDependenciesCheckbox.checked,
      onlyOutdated: outdatedOnlyCheckbox.checked,
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

  final nodes = _root.querySelectorAll('g.node').elements.map((e) {
    final element = e as SVGGElement;
    final title = element.querySelector('title')!.textContent!;
    element.id = title;

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
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

    // NOTE: we are assuming the shape of the generated SVG here – be careful!
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
      // then the hover-over is on a line!
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
          constraintCell = '<span class="outdated-edge">$constraintCell</span>';
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

    updateHudBox(depsInBox, 'INCOMING', fromDeps);
    updateHudBox(depsOutBox, 'OUTGOING', toDeps);
  } else {
    depsInBox.style.display = 'none';
    depsOutBox.style.display = 'none';
  }
}

@JS()
// ignore: non_constant_identifier_names
external VizClass get Viz;

extension type VizClass._(JSObject _) implements JSObject {
  external JSPromise<VizInstance> instance();
}

extension type VizInstance._(JSObject _) implements JSObject {
  external String renderString(String src, [RenderOptions options]);
}

extension type RenderOptions._(JSObject _) implements JSObject {
  external factory RenderOptions({String format});

  external String format;
}

extension on NodeList {
  Iterable<Element> get elements sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)! as Element;
    }
  }
}

extension on NamedNodeMap {
  String? operator [](String key) => getNamedItem(key)?.value;
}
