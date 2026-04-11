## 6.1.0-wip

- Add a `workspace` filter.
- Use a worker so the UI doesn't freeze when rendering big graphs.
- MUCH smaller WebAssembly module.

## 6.0.0

### Breaking Changes
- `VizRoot.forDirectory` has been replaced by the `vizRoot` extension method on
  `Service` to accommodate internal refactoring. `vizRoot` is exposed directly
  via `pubviz.dart`.
- Reduced the mutable public API surface of `VizRoot` significantly; package
  nodes and references are formally encapsulated, and filtering logic like
  `.filter` now returns immutable clones of `VizRoot` rather than mutating
  objects in-place.
- `VizRoot.allDeps` has been removed.
- Removed the `--action create` option.
- Removed the `--out-dir` option.

### Web UI Overhaul
- `--flag-outdated` now defaults to on.
- Added a filter to hide `dev_dependency` edges and nodes.
- Added a filter to only show paths to outdated dependencies.
- Assets are now served without creating a temp directory.

### New Features
- **Workspaces**: `pubviz` now automatically infers workspace context. 
  If run in a workspace root or member package, it natively visualizes the 
  layout for the entire workspace graph. The `--workspace` flag is now optional
  (`--[no-]workspace`).

### Bug Fixes
- **Workspaces**: Included missing relational web edges for `dev_dependencies`
  belonging to workspace sub-members. They previously rendered as disconnected
  nodes.

## 5.0.0

### Breaking Changes
- Replaced positional commands (`open`, `create`, `print`) and the `--format`
  option with a unified `--action` (`-a`) flag.
- Default execution (`pubviz`) now functions identically to `pubviz -a open`.
- Removed the `viz/dot.dart` library. `toDot` is now exposed via a an extension
  on `VizRoot`

### New Features
- **Workspaces:** Added the `--workspace` (`-w`) flag to visualize all linked
  packages within a Dart workspace.
- **Output Controls:** Added the `--out-dir` option to specify a target
  destination for generated HTML and offline capabilities.
- **Serve Mode & Offline Support:** Added the `serve` action which hosts the
  web app locally via `dhttpd` without booting up a new browser window. The
  `open` action now uses this local server to bypass strict `file://` CORS
  restrictions internally. Additionally, the package now supports complete
  offline functionality by bundling compiled Dart web application assets (JS
  and WASM) directly inside the package.

### Web UI Overhaul
- Completely redesigned the interactive web interface, adding a collapsible
  sidebar for cleaner zooming and display control.
- Added a `z` keyboard shortcut to easily toggle graph zoom capabilities.
- Improved graph styling: Primary packages now utilize a distinct background
  color to distinguish them easily.

### Other Improvements & Fixes
- Modernized workspace discovery inside the codebase by utilizing structured
  JSON data directly from `pub` tool invocations.
- Hide version labels for primary node packages intentionally marked
  `publish_to: none`.
- Display a helpful warning message if `pubviz` runs inside a workspace root
  missing the `--workspace` flag.
- Fixed a bug causing wrong colors on hover interactions over outdated packages.

- Require `sdk: ^3.10.0`.

## 4.1.1

- Fix issue with `script` tag.

## 4.1.0

- Added a printed output to `pubviz` when using the `-o` flag that provides a
  topologically sorted update order for outdated packages.
- Require `sdk: ^3.9.0`.

## 4.0.1

- Fix issue when package has dependency overrides.

## 4.0.0

- Support (Dart 3.6) workspaces.
- API refactoring to support workspaces.

## 3.0.1

- require at least Dart 3.5

## 3.0.0

- require at least Dart 2.18
- Allow latest `pkg:http`.

## 2.8.2+1

* Update README with instructions how to generate PDF, PNG or other files

## 2.8.2

* Handle a `null` output from `pub` without crashing.

## 2.8.1

* Copy valid package name parsing logic from `pub` tool.
  * Packages with `.` in their name are now allowed.

## 2.8.0

* Add new `--production-dependencies` flag to only output packages needed for
  production.
* Updated `--direct-dependencies` behavior to treat `dev_dependencies` the same
  as `dependencies`.
* Don't include `sky_engine` in output ever – it's just `dart:ui`.
* Bumped min Dart SDK to `2.8.1`.
* Implementation: use new `pub outdated` command.

## 2.7.0

* Added `--version` to CLI.
* Bumped min Dart SDK to 2.3.

## 2.6.0

* Add support for direct dependencies only with `--direct-dependencies` (`-d`).

## 2.5.5

* Update dependencies.

## 2.5.4

* Improve the package description.

* Update some dependencies.

## 2.5.3

* Support Dart 2 stable.

## 2.5.2

* Fixes for Dart 2 type system.

## 2.5.1

* Stop using deprecated HTTP constants.

## 2.5.0

* Use `pkg:pubspec_parse` package.

* Stop using deprecated constants.

* Improve handling of pre-release packages.

## 2.4.5

* Fix for latest Flutter SDK.

## 2.4.4

* Fixed code organization to eliminate warning during `pub global activate`.

## 2.4.3

* Improvements in CLI error handling and help.

## 2.4.2

* Updated output format.

* And other cleanup...

## 2.4.1

* Using `nodesep=0.2` on the graph to make it tighter.

* Hosted code

  * Much more robust handling of node clicks to add/remove.

  * Make it clear that nodes can be clicked by changing the cursor.

## 2.4.0

* Better error output if a subprocess fails.

* Try to handle flutter packages. 

## 2.3.11

* Better hover-over behavior for outdated dependencies.

## 2.3.10

* Update `gviz`.

* Support larger dependency graphs.

* Update version of `viz.js`.

* Use `viz-lite.js` – smaller download.
  * Continue to host `vis.js` so we don't break existing installations.

## 2.3.9+1

* Use `gviz` package. Get out of the GraphViz formatting business.

## 2.3.9

* Updated dependencies.

* Fix case where we're pulling in a pre-release version that is after the
  latest stable version.

## 2.3.8

* Send a descriptive user agent to the server.

* Added retry logic for HTTP requests.

* Sort the output.

## 2.3.7

* Better stack trace on errors.

## 2.3.6

* Cleanup, handled some deprecations, improve load time.

## 2.3.5

* Tweaks test code, examples, dependencies.

## 2.3.4

* Properly escape the latest version for outdated dependencies.

* Add a reasonable tool-tip for the entire graph.

* Don't show the root node as outdated.

## 2.3.3

* Using CSS animations for effects. Hosting style on GitHub.

## 2.3.2

* All fancy with mouse-over effects.

## 2.3.1+1

* Fix `README.md`.

## 2.3.1

* With `--flag-outdated` (`-o`) do version lookup in parallel. *MUCH* faster.

## 2.3.0

* Allow ignoring packages via `--ignore-packages`.
  *Thanks, [Günter](https://github.com/zoechi)!*

* A fix for running on Windows.
  *Thanks, [Oliver](https://github.com/Fox32)!*

* A fix for formatting packages with hyphens.
  *Thanks, [Bryon](https://github.com/bryonmarks)!*
