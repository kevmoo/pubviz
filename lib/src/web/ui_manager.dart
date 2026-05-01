import 'dart:async';
import 'dart:convert' show htmlEscape;
import 'dart:js_interop';

import 'package:web/web.dart';

import '../options.dart';
import '../version.dart';

import 'pubviz_app.dart';

typedef _FilterConfig = ({
  String key,
  String id,
  String labelText,
  String? filterKey,
  bool Function() isAvailable,
  void Function(HTMLInputElement checkbox) onChanged,
  String enabledMessage,
  String disabledMessage,
  String unavailableMessage,
  String Function() availableTooltip,
  String Function() unavailableTooltip,
});

final _hotkeyRegex = RegExp(r'^[a-zA-Z]$');

final class UIManager {
  final PubvizApp _app;

  final HTMLInputElement _hamburgerCheckbox =
      document.querySelector('#controlsToggle') as HTMLInputElement;
  final HTMLLabelElement _hamburgerLabel =
      document.querySelector('#hamburgerLabel') as HTMLLabelElement;
  final HTMLDivElement _depsInBox =
      document.querySelector('#deps-in-box') as HTMLDivElement;
  final HTMLDivElement _depsOutBox =
      document.querySelector('#deps-out-box') as HTMLDivElement;
  final HTMLDivElement _toast =
      document.querySelector('#toast') as HTMLDivElement;
  final HTMLDivElement _mobileOverlay =
      document.querySelector('#mobile-overlay') as HTMLDivElement;

  late final _checkboxes = <String, HTMLInputElement>{};
  late final HTMLButtonElement _resetButton;

  late final _filterConfigs = <_FilterConfig>[
    (
      key: 'z',
      id: 'zoomCheckbox',
      labelText: 'Zoom (z)',
      filterKey: null,
      isAvailable: () => true,
      onChanged: (_) => _app.updateZoom(),
      enabledMessage: 'Zoom Enabled',
      disabledMessage: 'Zoom Disabled',
      unavailableMessage: '',
      availableTooltip: () =>
          'Toggle pan and zoom capabilities across the graph.',
      unavailableTooltip: () => '',
    ),
    (
      key: 'd',
      id: 'devDependenciesCheckbox',
      labelText: 'Hide Dev Deps (d)',
      filterKey: filterHideDev,
      isAvailable: () => _app.hasDevDependencies,
      onChanged: (_) => _triggerRender(),
      enabledMessage: 'Hiding Dev Dependencies',
      disabledMessage: 'Showing Dev Dependencies',
      unavailableMessage: 'No Dev Dependencies to Filter',
      availableTooltip: () =>
          'Hide all packages that are only utilized during development.',
      unavailableTooltip: () => 'No dev dependencies found.',
    ),
    (
      key: 'w',
      id: 'workspaceOnlyCheckbox',
      labelText: 'Workspace Only (w)',
      filterKey: filterWorkspace,
      isAvailable: () => _app.isWorkspace,
      onChanged: (_) => _triggerRender(),
      enabledMessage: 'Showing Only Workspace',
      disabledMessage: 'Showing All Packages',
      unavailableMessage: 'Not a workspace (only one package)',
      availableTooltip: () =>
          'Filter the view to exclusively show packages within the current '
          'workspace.',
      unavailableTooltip: () => 'Not a workspace (only one package).',
    ),
    (
      key: 'i',
      id: 'hideIsolatedCheckbox',
      labelText: 'Hide Isolated (i)',
      filterKey: filterHideIsolated,
      isAvailable: () => _app.hasIsolatedPackages,
      onChanged: (_) => _triggerRender(),
      enabledMessage: 'Hiding Isolated Packages',
      disabledMessage: 'Showing Isolated Packages',
      unavailableMessage: 'No isolated packages to filter',
      availableTooltip: () =>
          'Hide workspace packages that aren\'t reachable from published '
          'members.',
      unavailableTooltip: () => !_app.isWorkspace
          ? 'Not a workspace (only one package).'
          : 'No isolated packages found.',
    ),
    (
      key: 'o',
      id: 'outdatedOnlyCheckbox',
      labelText: 'Outdated Only (o)',
      filterKey: filterOutdated,
      isAvailable: () => _app.hasOutdated,
      onChanged: (_) => _triggerRender(),
      enabledMessage: 'Showing Only Outdated',
      disabledMessage: 'Showing All Packages',
      unavailableMessage: 'No Outdated Packages to Filter',
      availableTooltip: () =>
          'Filter the view to exclusively highlight outdated packages.',
      unavailableTooltip: () => 'No outdated packages found.',
    ),
  ];

  Timer? _toastTimer;

  UIManager(this._app) {
    final controlsContent =
        document.querySelector('#controls-content') as HTMLDivElement
          ..innerHTML = ''.toJS;

    for (final config in _filterConfigs) {
      final label = document.createElement('label') as HTMLLabelElement;
      final checkbox = document.createElement('input') as HTMLInputElement
        ..type = 'checkbox'
        ..id = config.id;

      label
        ..appendChild(checkbox)
        ..appendChild(document.createTextNode(' ${config.labelText}'));
      controlsContent.appendChild(label);

      _checkboxes[config.id] = checkbox;

      if (!config.isAvailable()) {
        checkbox.disabled = true;
        if (config.unavailableTooltip().isNotEmpty) {
          label.title = config.unavailableTooltip();
        }
      } else {
        if (config.availableTooltip().isNotEmpty) {
          label.title = config.availableTooltip();
        }
      }
    }

    _resetButton = document.createElement('button') as HTMLButtonElement
      ..id = 'resetButton'
      ..textContent = 'Reset (r)'
      ..disabled = true;

    controlsContent.appendChild(_resetButton);

    _resetButton.onClick.listen((_) => _resetFilters());

    _applyHashFilters();
    _updateNonDefaultDot();
    _updateResetButtonState();

    document.body!.onWheel.listen((e) {
      if ((e.target as Element).closest('.hud-box') != null) {
        e.stopPropagation();
      }
    });

    document.body!.onChange.listen((e) {
      final target = e.target as Element;
      if (target.id == 'controlsToggle') {
        showToast(
          _hamburgerCheckbox.checked ? 'Controls Shown' : 'Controls Hidden',
        );
        _updateNonDefaultDot();
        return;
      }

      for (final config in _filterConfigs) {
        if (config.id == target.id) {
          config.onChanged(_checkboxes[config.id]!);
          _updateNonDefaultDot();
          _updateResetButtonState();
          return;
        }
      }
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

  void _triggerRender() {
    _updateHash();
    unawaited(_app.render());
  }

  bool get zoomEnabled => _checkboxes['zoomCheckbox']!.checked;

  bool get hideDevDependencies =>
      _checkboxes['devDependenciesCheckbox']!.checked;

  bool get outdatedOnly => _checkboxes['outdatedOnlyCheckbox']!.checked;

  bool get workspaceOnly => _checkboxes['workspaceOnlyCheckbox']!.checked;

  bool get hideIsolatedPackages => _checkboxes['hideIsolatedCheckbox']!.checked;

  void _toggleControls() {
    _hamburgerCheckbox.checked = !_hamburgerCheckbox.checked;
    showToast(
      _hamburgerCheckbox.checked ? 'Controls Shown' : 'Controls Hidden',
    );
  }

  void _resetFilters() {
    var anyChanged = false;
    for (final config in _filterConfigs) {
      final checkbox = _checkboxes[config.id]!;
      if (checkbox.checked) {
        checkbox.checked = false;
        if (config.id == 'zoomCheckbox') {
          _app.updateZoom();
        }
        anyChanged = true;
      }
    }
    if (anyChanged) {
      _updateHash();
      unawaited(_app.render());
      _updateNonDefaultDot();
      _updateResetButtonState();
      showToast('Filters Reset');
    }
  }

  void _updateResetButtonState() {
    final anyChecked = _checkboxes.values.any((cb) => cb.checked);
    _resetButton.disabled = !anyChecked;
    _resetButton.title = anyChecked
        ? 'Restore all filters to their default unchecked states.'
        : 'All filters are already at their default states.';
  }

  void _handleKeyDown(KeyboardEvent event) {
    if (event.ctrlKey || event.metaKey || event.altKey) {
      return;
    }

    final key = event.key.toLowerCase();

    for (final config in _filterConfigs) {
      if (config.key == key) {
        _toggleFilter(config);
        return;
      }
    }

    switch (key) {
      case 'c':
        _toggleControls();
      case 'r':
        if (!_resetButton.disabled) {
          _resetFilters();
        }
      default:
        if (_hotkeyRegex.hasMatch(event.key)) {
          showToast('❓ Unknown hot key: ${event.key}');
        }
    }
  }

  void _toggleFilter(_FilterConfig config) {
    if (config.isAvailable()) {
      final checkbox = _checkboxes[config.id]!;
      checkbox.checked = !checkbox.checked;
      config.onChanged(checkbox);
      showToast(
        checkbox.checked ? config.enabledMessage : config.disabledMessage,
      );
      _updateResetButtonState();
    } else {
      showToast('⚠️ ${config.unavailableMessage}');
    }
    _updateNonDefaultDot();
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

      for (final config in _filterConfigs) {
        if (config.filterKey case final filterKey?) {
          final checkbox = _checkboxes[config.id]!;
          if (filterKey == filterOutdated && !_app.hasOutdated) {
            continue;
          }
          checkbox.checked = filters.contains(filterKey);
        }
      }
    }
  }

  void _updateHash() {
    final filters = <String>{};
    for (final config in _filterConfigs) {
      if (config.filterKey case final filterKey?) {
        if (_checkboxes[config.id]!.checked) {
          filters.add(filterKey);
        }
      }
    }

    if (filters.isEmpty) {
      window.history.replaceState(null, '', window.location.pathname);
    } else {
      window.history.replaceState(null, '', '#/filters=${filters.join(',')}');
    }
  }

  void _updateNonDefaultDot() {
    final isNonDefault = _filterConfigs.any(
      (config) => config.filterKey != null && _checkboxes[config.id]!.checked,
    );

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
