import 'dart:async';
import 'dart:convert' show LineSplitter;
import 'dart:js_interop';

import 'package:web/web.dart';

import '../dot.dart';
import '../viz_root.dart';

import 'interop.dart';
import 'pubviz_app.dart';

typedef _GraphNode = ({SVGGElement element, String id, bool isOutdated});

typedef _GraphEdge = ({
  SVGGElement element,
  String from,
  String to,
  String constraint,
  bool isDev,
  bool isOutdated,
});

final class _CancellationException implements Exception {
  const _CancellationException();
  @override
  String toString() => 'Cancelled';
}

final class GraphRenderer {
  final PubvizApp _app;
  SVGElement? __root;
  SVGGElement? _lockedElement;
  VizRoot? _currentRoot;

  int _renderGeneration = 0;
  Worker? _currentWorker;
  Completer<String>? _currentCompleter;

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
    final generation = ++_renderGeneration;

    // TODO(kevmoo): Move this into the UI manager
    final loadingOverlay = document.querySelector('#loading-overlay');
    loadingOverlay?.classList.remove('hidden');

    // Yield to allow the browser to render the loading overlay.
    await Future<void>.delayed(Duration.zero);

    final watch = Stopwatch()..start();
    try {
      final filteredRoot = _app.originalVizRoot.filter(
        excludeDev: _app.ui.hideDevDependencies,
        onlyOutdated: _app.ui.outdatedOnly,
        onlyWorkspace: _app.ui.workspaceOnly,
        hideIsolated: _app.ui.hideIsolated,
      );

      _currentRoot = filteredRoot;
      final dotString = filteredRoot.toDot();

      final output = await _renderWithWorker(dotString, generation);

      if (generation != _renderGeneration) {
        return;
      }

      _updateBody(output);
    } catch (e, stack) {
      if (e is _CancellationException) {
        return;
      }
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
      if (generation == _renderGeneration) {
        loadingOverlay?.classList.add('hidden');
        console.info('Total time generating graph: ${watch.elapsed}'.toJS);
      }
    }
  }

  Future<String> _renderWithWorker(String dotString, int generation) {
    final oldCompleter = _currentCompleter;
    if (oldCompleter != null && !oldCompleter.isCompleted) {
      oldCompleter.completeError(const _CancellationException());
    }

    final completer = Completer<String>();
    _currentCompleter = completer;

    if (_currentWorker == null) {
      final worker = Worker('viz_worker.js'.toJS);
      _currentWorker = worker;

      worker
        ..onmessage = _onWorkerMessage.toJS
        ..onerror = (Event event) {
          final activeCompleter = _currentCompleter;
          if (activeCompleter != null && !activeCompleter.isCompleted) {
            activeCompleter.completeError('Worker error');
          }
          worker.terminate();
          if (_currentWorker == worker) {
            _currentWorker = null;
            _currentCompleter = null;
          }
        }.toJS;
    }

    _currentWorker!.postMessage(
      RenderMessage(
        dotString: dotString,
        options: RenderOptions(format: 'svg'),
        generation: generation,
      ),
    );

    return completer.future;
  }

  void _onWorkerMessage(MessageEvent event) {
    final response = event.data as RenderResponse;
    if (response.generation != _renderGeneration) return;

    final activeCompleter = _currentCompleter;
    if (activeCompleter == null || activeCompleter.isCompleted) return;

    if (response.success) {
      activeCompleter.complete(response.output);
    } else {
      activeCompleter.completeError(
        '${response.error}\n${response.stack ?? ''}',
      );
    }
    if (_currentCompleter == activeCompleter) {
      _currentCompleter = null;
    }
  }

  void _updateBody(String output) {
    if (__root != null) {
      __root!.remove();
      __root = null;
      _lockedElement = null;
    }

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

    final nodes = _root.querySelectorAll('g.node').elements.map((e) {
      final element = e as SVGGElement;
      final title = element.querySelector('title')!.textContent!;
      element.id = title;

      final pkg = _currentRoot!.packages[title];
      final isOutdated = pkg?.isOutdated ?? false;

      if (isOutdated) {
        element.classList.add('outdated');
      }

      return (element: element, id: title, isOutdated: isOutdated);
    }).toList();

    final edges = _root.querySelectorAll('g.edge').elements.map((e) {
      final node = e as SVGGElement;
      final title = node.querySelector('title')!.textContent!;
      final things = title.split('->');
      final from = things[0];
      final to = things[1];

      final pkgFrom = _currentRoot!.packages[from];
      final dep = pkgFrom?.dependencies.where((d) => d.name == to).firstOrNull;
      final constraint = dep?.versionConstraint.toString() ?? '';
      final isDev = dep?.isDevDependency ?? false;
      final isOutdated = dep?.includesLatest == false;

      if (isOutdated) {
        node.classList.add('outdated');
      }

      return (
        element: node,
        from: from,
        to: to,
        constraint: constraint,
        isDev: isDev,
        isOutdated: isOutdated,
      );
    }).toList();

    _attachListeners(nodes, edges);
  }

  void _attachListeners(List<_GraphNode> nodes, List<_GraphEdge> edges) {
    _root.onMouseOver.listen((MouseEvent event) {
      final target =
          (event.target as Element).closest('g.node, g.edge') as SVGGElement?;
      final related = (event.relatedTarget as Element?)?.closest(
        'g.node, g.edge',
      ) as SVGGElement?;

      if (target == related) return;

      final text = target
          ?.querySelectorAll('text')
          .elements
          .map((e) => e.textContent?.trim() ?? '')
          .where((t) => t.isNotEmpty)
          .join(' ');
      if (text != null && text.isNotEmpty) {
        _app.ui.showToast(text);
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
        _lockedElement = _lockedElement == target ? null : target;
        _updateOver(target, nodes, edges);
      } else if (_lockedElement != null) {
        _lockedElement = null;
        _updateOver(null, nodes, edges);
      }
    });
  }

  void _updateOver(
    SVGGElement? element,
    Iterable<_GraphNode> nodes,
    Iterable<_GraphEdge> edges,
  ) {
    final targetPkg = switch (element) {
      null => const <String>[],
      _ when element.classList.contains('edge') =>
        element
            .querySelector('title')!
            .textContent!
            .split('->')
            .reversed
            .toList(),
      _ => [element.id],
    };

    for (final node in nodes) {
      node.element.classList
        ..toggle('active', targetPkg.contains(node.id))
        ..toggle('locked', node.element == _lockedElement);
    }

    final singleTarget = targetPkg.length == 1 ? targetPkg.first : null;
    final fromDeps = <DepInfo>[];
    final toDeps = <DepInfo>[];
    for (final edge in edges) {
      final isActive = targetPkg.length == 2
          ? (targetPkg.contains(edge.to) && targetPkg.contains(edge.from))
          : (targetPkg.contains(edge.to) || targetPkg.contains(edge.from));

      edge.element.classList
        ..toggle('active', isActive)
        ..toggle('locked', edge.element == _lockedElement);

      DepInfo makeDepInfo(String name) => (
        name: name,
        constraint: edge.constraint,
        isDev: edge.isDev,
        isNodeOutdated: nodes.firstWhere((n) => n.id == name).isOutdated,
        isEdgeOutdated: edge.isOutdated,
      );

      if (edge.to == singleTarget) {
        fromDeps.add(makeDepInfo(edge.from));
      }
      if (edge.from == singleTarget) {
        toDeps.add(makeDepInfo(edge.to));
      }
    }

    _app.ui.updateBoxes(fromDeps: fromDeps, toDeps: toDeps);
  }
}
