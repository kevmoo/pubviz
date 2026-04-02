import 'dart:async';

import 'package:pubviz/src/version.dart';
import 'package:web/web.dart';

import 'pubviz_app.dart';

final class UIManager {
  final PubvizApp app;
  final HTMLButtonElement hamburgerBtn =
      document.querySelector('#hamburgerBtn') as HTMLButtonElement;
  final HTMLDivElement controlsPanel =
      document.querySelector('#controls-panel') as HTMLDivElement;
  final HTMLInputElement zoomCheckbox =
      document.querySelector('#zoomCheckbox') as HTMLInputElement;
  final HTMLInputElement devDependenciesCheckbox =
      document.querySelector('#devDependenciesCheckbox') as HTMLInputElement;
  final HTMLDivElement outdatedCheckboxContainer =
      document.querySelector('#outdatedCheckboxContainer') as HTMLDivElement;
  final HTMLInputElement outdatedOnlyCheckbox =
      document.querySelector('#outdatedOnlyCheckbox') as HTMLInputElement;
  final HTMLDivElement depsInBox =
      document.querySelector('#deps-in-box') as HTMLDivElement;
  final HTMLDivElement depsOutBox =
      document.querySelector('#deps-out-box') as HTMLDivElement;

  Timer? _toastTimer;

  UIManager(this.app) {
    if (!app.hasOutdated) {
      outdatedOnlyCheckbox.disabled = true;
      outdatedCheckboxContainer.title = 'No outdated packages found.';
    }

    depsInBox.onWheel.listen((e) => e.stopPropagation());
    depsOutBox.onWheel.listen((e) => e.stopPropagation());

    hamburgerBtn.onClick.listen((_) => toggleControls());

    zoomCheckbox.onChange.listen((_) => app.renderer.toggleZoomStyle());

    devDependenciesCheckbox.onChange.listen((_) {
      unawaited(app.renderer.render());
    });
    outdatedOnlyCheckbox.onChange.listen((_) {
      unawaited(app.renderer.render());
    });

    window.onKeyDown.listen(_handleKeyDown);

    (document.querySelector('#version') as HTMLSpanElement).textContent =
        'v$packageVersion';
  }

  void toggleControls() {
    controlsPanel.classList.toggle('collapsed');
  }

  void _handleKeyDown(KeyboardEvent event) {
    switch (event.key) {
      case 'c' || 'C':
        toggleControls();
        showToast(
          controlsPanel.classList.contains('collapsed')
              ? 'Controls Hidden'
              : 'Controls Shown',
        );
      case 'z' || 'Z':
        zoomCheckbox.checked = !zoomCheckbox.checked;
        app.renderer.toggleZoomStyle();
        showToast(zoomCheckbox.checked ? 'Zoom Enabled' : 'Zoom Disabled');
      case 'd' || 'D':
        devDependenciesCheckbox.checked = !devDependenciesCheckbox.checked;
        unawaited(app.renderer.render());
        showToast(
          devDependenciesCheckbox.checked
              ? 'Showing Dev Dependencies'
              : 'Hiding Dev Dependencies',
        );
      case 'o' || 'O':
        if (app.hasOutdated) {
          outdatedOnlyCheckbox.checked = !outdatedOnlyCheckbox.checked;
          unawaited(app.renderer.render());
          showToast(
            outdatedOnlyCheckbox.checked
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
}
