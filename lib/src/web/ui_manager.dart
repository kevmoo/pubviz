import 'dart:async';
import 'dart:convert' show htmlEscape;
import 'dart:js_interop';

import 'package:web/web.dart';

import '../options.dart';
import '../version.dart';

import 'pubviz_app.dart';

typedef _FilterConfig = ({
  String key,
  bool Function() isAvailable,
  HTMLInputElement checkbox,
  String enabledMessage,
  String disabledMessage,
  String unavailableMessage,
});

final class UIManager {
  final PubvizApp _app;

  final HTMLInputElement _hamburgerCheckbox =
      document.querySelector('#controlsToggle') as HTMLInputElement;
  final HTMLLabelElement _hamburgerLabel =
      document.querySelector('#hamburgerLabel') as HTMLLabelElement;
  final HTMLInputElement _zoomCheckbox =
      document.querySelector('#zoomCheckbox') as HTMLInputElement;
  final HTMLInputElement _devDependenciesCheckbox =
      document.querySelector('#devDependenciesCheckbox') as HTMLInputElement;
  final HTMLDivElement _outdatedCheckboxContainer =
      document.querySelector('#outdatedCheckboxContainer') as HTMLDivElement;
  final HTMLInputElement _outdatedOnlyCheckbox =
      document.querySelector('#outdatedOnlyCheckbox') as HTMLInputElement;
  final HTMLInputElement _workspaceOnlyCheckbox =
      document.querySelector('#workspaceOnlyCheckbox') as HTMLInputElement;
  final HTMLDivElement _depsInBox =
      document.querySelector('#deps-in-box') as HTMLDivElement;
  final HTMLDivElement _depsOutBox =
      document.querySelector('#deps-out-box') as HTMLDivElement;
  final HTMLDivElement _toast =
      document.querySelector('#toast') as HTMLDivElement;
  final HTMLDivElement _mobileOverlay =
      document.querySelector('#mobile-overlay') as HTMLDivElement;

  late final _filterConfigs = <_FilterConfig>[
    (
      key: 'd',
      isAvailable: () => _app.hasDevDependencies,
      checkbox: _devDependenciesCheckbox,
      enabledMessage: 'Hiding Dev Dependencies',
      disabledMessage: 'Showing Dev Dependencies',
      unavailableMessage: 'No Dev Dependencies to Filter',
    ),
    (
      key: 'w',
      isAvailable: () => _app.isWorkspace,
      checkbox: _workspaceOnlyCheckbox,
      enabledMessage: 'Showing Only Workspace',
      disabledMessage: 'Showing All Packages',
      unavailableMessage: 'Not a workspace (only one package)',
    ),
    (
      key: 'o',
      isAvailable: () => _app.hasOutdated,
      checkbox: _outdatedOnlyCheckbox,
      enabledMessage: 'Showing Only Outdated',
      disabledMessage: 'Showing All Packages',
      unavailableMessage: 'No Outdated Packages to Filter',
    ),
  ];

  Timer? _toastTimer;

  UIManager(this._app) {
    if (!_app.hasOutdated) {
      _outdatedOnlyCheckbox.disabled = true;
      _outdatedCheckboxContainer.title = 'No outdated packages found.';
    }
    if (!_app.hasDevDependencies) {
      _devDependenciesCheckbox.disabled = true;
      final parent = _devDependenciesCheckbox.parentNode;
      if (parent != null && parent.nodeType == 1) {
        (parent as HTMLElement).title = 'No dev dependencies found.';
      }
    }
    if (!_app.isWorkspace) {
      _workspaceOnlyCheckbox.disabled = true;
      final parent = _workspaceOnlyCheckbox.parentNode;
      if (parent != null && parent.nodeType == 1) {
        (parent as HTMLElement).title = 'Not a workspace (only one package).';
      }
    }
    _applyHashFilters();
    _updateNonDefaultDot();

    document.body!.onWheel.listen((e) {
      if ((e.target as Element).closest('.hud-box') != null) {
        e.stopPropagation();
      }
    });

    document.body!.onChange.listen((e) {
      final target = e.target as Element;
      switch (target.id) {
        case 'controlsToggle':
          showToast(
            _hamburgerCheckbox.checked ? 'Controls Shown' : 'Controls Hidden',
          );
        case 'zoomCheckbox':
          _app.updateZoom();
        case 'devDependenciesCheckbox' ||
            'outdatedOnlyCheckbox' ||
            'workspaceOnlyCheckbox':
          _updateHash();
          unawaited(_app.render());
      }
      _updateNonDefaultDot();
    });

    document.body!.onClick.listen((e) {
      final target = e.target as Element;
      if (target.id == 'dismissMobileWarning') {
        _mobileOverlay.classList.add('hidden');
      }
    });

    window.onKeyDown.listen(_handleKeyDown);

    (document.querySelector('#version') as HTMLSpanElement).textContent =
        'v$packageVersion';
  }

  bool get zoomEnabled => _zoomCheckbox.checked;

  bool get hideDevDependencies => _devDependenciesCheckbox.checked;

  bool get outdatedOnly => _outdatedOnlyCheckbox.checked;

  bool get workspaceOnly => _workspaceOnlyCheckbox.checked;

  void _toggleControls() {
    _hamburgerCheckbox.checked = !_hamburgerCheckbox.checked;
    showToast(
      _hamburgerCheckbox.checked ? 'Controls Shown' : 'Controls Hidden',
    );
  }

  void _handleKeyDown(KeyboardEvent event) {
    final key = event.key.toLowerCase();

    for (final config in _filterConfigs) {
      if (config.key == key) {
        _toggleFilter(
          isAvailable: config.isAvailable(),
          checkbox: config.checkbox,
          enabledMessage: config.enabledMessage,
          disabledMessage: config.disabledMessage,
          unavailableMessage: config.unavailableMessage,
        );
        return;
      }
    }

    switch (key) {
      case 'c':
        _toggleControls();
      case 'z':
        _zoomCheckbox.checked = !_zoomCheckbox.checked;
        _app.updateZoom();
        showToast(zoomEnabled ? 'Zoom Enabled' : 'Zoom Disabled');
      default:
        if (RegExp(r'^[a-zA-Z]$').hasMatch(event.key)) {
          showToast('❓ Unknown hot key: ${event.key}');
        }
    }
    _updateNonDefaultDot();
  }

  void _toggleFilter({
    required bool isAvailable,
    required HTMLInputElement checkbox,
    required String enabledMessage,
    required String disabledMessage,
    required String unavailableMessage,
  }) {
    if (isAvailable) {
      checkbox.checked = !checkbox.checked;
      _updateHash();
      unawaited(_app.render());
      showToast(checkbox.checked ? enabledMessage : disabledMessage);
    } else {
      showToast('⚠️ $unavailableMessage');
    }
  }

  void showToast(String message) {
    _toast.textContent = message;

    _toast.classList.remove('show');
    _toast.classList.remove('pop');

    _toast.offsetHeight;

    _toast.classList.add('show');
    _toast.classList.add('pop');

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1500), () {
      _toast.classList.remove('show');
      _toast.classList.remove('pop');
    });
  }

  void updateBoxes({
    required List<DepInfo> fromDeps,
    required List<DepInfo> toDeps,
  }) {
    if (fromDeps.isEmpty && toDeps.isEmpty) {
      _depsInBox.style.display = 'none';
      _depsOutBox.style.display = 'none';
      return;
    }

    final sortedFrom = List<DepInfo>.from(fromDeps)
      ..sort((a, b) => a.name.compareTo(b.name));
    final sortedTo = List<DepInfo>.from(toDeps)
      ..sort((a, b) => a.name.compareTo(b.name));

    _updateHudBox(_depsInBox, 'INCOMING', sortedFrom);
    _updateHudBox(_depsOutBox, 'OUTGOING', sortedTo);
  }

  void _applyHashFilters() {
    final hash = window.location.hash;
    if (hash.startsWith('#/filters=')) {
      final filtersStr = hash.substring('#/filters='.length);
      final filters = filtersStr.split(',');

      _devDependenciesCheckbox.checked = filters.contains(filterHideDev);
      _workspaceOnlyCheckbox.checked = filters.contains(filterWorkspace);
      if (_app.hasOutdated) {
        _outdatedOnlyCheckbox.checked = filters.contains(filterOutdated);
      }
    }
  }

  void _updateHash() {
    final filters = <String>{};
    if (_devDependenciesCheckbox.checked) filters.add(filterHideDev);
    if (_workspaceOnlyCheckbox.checked) filters.add(filterWorkspace);
    if (_outdatedOnlyCheckbox.checked) filters.add(filterOutdated);

    if (filters.isEmpty) {
      window.history.replaceState(null, '', window.location.pathname);
    } else {
      window.history.replaceState(null, '', '#/filters=${filters.join(',')}');
    }
  }

  void _updateNonDefaultDot() {
    final isNonDefault =
        _devDependenciesCheckbox.checked ||
        _workspaceOnlyCheckbox.checked ||
        _outdatedOnlyCheckbox.checked;

    if (isNonDefault) {
      _hamburgerLabel.classList.add('non-default');
    } else {
      _hamburgerLabel.classList.remove('non-default');
    }
  }

  void showCrashReport(String error, String stackTrace) {
    (document.querySelector('#crash-trace') as HTMLPreElement).textContent =
        '$error\n$stackTrace';
    (document.querySelector('#crash-overlay') as HTMLDivElement).classList
        .remove('hidden');
    (document.querySelector('#graph-container') as HTMLDivElement).classList
        .add('hidden');
  }
}

void _updateHudBox(HTMLDivElement box, String title, List<DepInfo> deps) {
  if (deps.isNotEmpty) {
    box.style.display = 'flex';
    box.innerHTML =
        '<h3>$title</h3><div class="table-scroll">${_buildTable(deps)}</div>'
            .toJS;
  } else {
    box.style.display = 'none';
  }
}

String _buildTable(Iterable<DepInfo> deps) {
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
