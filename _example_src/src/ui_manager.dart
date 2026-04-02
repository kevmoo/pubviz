import 'dart:async';
import 'dart:convert' show htmlEscape;
import 'dart:js_interop';

import 'package:pubviz/src/version.dart';
import 'package:web/web.dart';

import 'pubviz_app.dart';

final class UIManager {
  final PubvizApp _app;

  final HTMLButtonElement _hamburgerBtn =
      document.querySelector('#hamburgerBtn') as HTMLButtonElement;
  final HTMLDivElement _controlsPanel =
      document.querySelector('#controls-panel') as HTMLDivElement;
  final HTMLInputElement _zoomCheckbox =
      document.querySelector('#zoomCheckbox') as HTMLInputElement;
  final HTMLInputElement _devDependenciesCheckbox =
      document.querySelector('#devDependenciesCheckbox') as HTMLInputElement;
  final HTMLDivElement _outdatedCheckboxContainer =
      document.querySelector('#outdatedCheckboxContainer') as HTMLDivElement;
  final HTMLInputElement _outdatedOnlyCheckbox =
      document.querySelector('#outdatedOnlyCheckbox') as HTMLInputElement;
  final HTMLDivElement _depsInBox =
      document.querySelector('#deps-in-box') as HTMLDivElement;
  final HTMLDivElement _depsOutBox =
      document.querySelector('#deps-out-box') as HTMLDivElement;

  Timer? _toastTimer;

  UIManager(this._app) {
    if (!_app.hasOutdated) {
      _outdatedOnlyCheckbox.disabled = true;
      _outdatedCheckboxContainer.title = 'No outdated packages found.';
    }

    _depsInBox.onWheel.listen((e) => e.stopPropagation());
    _depsOutBox.onWheel.listen((e) => e.stopPropagation());

    _hamburgerBtn.onClick.listen((_) => toggleControls());

    _zoomCheckbox.onChange.listen((_) => _app.toggleZoomStyle());

    _devDependenciesCheckbox.onChange.listen((_) {
      unawaited(_app.render());
    });
    _outdatedOnlyCheckbox.onChange.listen((_) {
      unawaited(_app.render());
    });

    window.onKeyDown.listen(_handleKeyDown);

    (document.querySelector('#version') as HTMLSpanElement).textContent =
        'v$packageVersion';
  }

  bool get zoomEnabled => _zoomCheckbox.checked;

  bool get devDependencies => _devDependenciesCheckbox.checked;

  bool get outdatedOnly => _outdatedOnlyCheckbox.checked;

  void toggleControls() {
    _controlsPanel.classList.toggle('collapsed');
  }

  void _handleKeyDown(KeyboardEvent event) {
    switch (event.key) {
      case 'c' || 'C':
        toggleControls();
        showToast(
          _controlsPanel.classList.contains('collapsed')
              ? 'Controls Hidden'
              : 'Controls Shown',
        );
      case 'z' || 'Z':
        _zoomCheckbox.checked = !_zoomCheckbox.checked;
        _app.toggleZoomStyle();
        showToast(_zoomCheckbox.checked ? 'Zoom Enabled' : 'Zoom Disabled');
      case 'd' || 'D':
        _devDependenciesCheckbox.checked = !_devDependenciesCheckbox.checked;
        unawaited(_app.render());
        showToast(
          _devDependenciesCheckbox.checked
              ? 'Showing Dev Dependencies'
              : 'Hiding Dev Dependencies',
        );
      case 'o' || 'O':
        if (_app.hasOutdated) {
          _outdatedOnlyCheckbox.checked = !_outdatedOnlyCheckbox.checked;
          unawaited(_app.render());
          showToast(
            _outdatedOnlyCheckbox.checked
                ? 'Showing Only Outdated'
                : 'Showing All Packages',
          );
        } else {
          showToast('No Outdated Packages to Filter');
        }
    }
  }

  void showToast(String message) {
    final toast = document.querySelector('#toast') as HTMLDivElement
      ..textContent = message;

    toast.classList.remove('show');
    toast.classList.remove('pop');

    toast.offsetHeight;

    toast.classList.add('show');
    toast.classList.add('pop');

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1500), () {
      toast.classList.remove('show');
      toast.classList.remove('pop');
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
