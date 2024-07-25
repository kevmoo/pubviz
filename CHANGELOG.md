## 3.0.1-wip

- require at least Dart 3.4

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
