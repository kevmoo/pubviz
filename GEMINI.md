# Pubviz AI Agent Instructions

These instructions help guide AI agents when making changes to this repository.

## Web Assets Workflow (`web` vs `lib/src/assets.g.dart`)

The `pubviz` application includes a compiled web frontend that is embedded
directly into Dart source code as pre-gzipped Base64 strings. It is critical to
understand the workflow between source files and compiled outputs:

1. **Source of Truth (`web/`)**:
   - All web application source code (HTML, CSS, Dart) lives in the `web`
     directory.
   - **Make all web-related UI or logic edits here.**

2. **Compiled Embedded Output (`lib/src/assets.g.dart`)**:
   - This generated file contains the pre-gzipped assets embedded directly in
     Dart code to guarantee 100% standalone, offline functionality.
   - It also embeds `assetInputsHash`, which tracks the `SHA-256` hashes of the
     input files (`web`, `lib/src`, `build.yaml`, `pubspec.yaml`) to ensure the
     cache isn't stale.

3. **Rebuilding Assets**:
   - Whenever you modify _anything_ in `web/`, `lib/`, `build.yaml`, or
     `pubspec.yaml`, you **MUST** run the following command to recompile the
     assets and update `lib/src/assets.g.dart`:
     ```bash
     dart tool/update_assets.dart
     ```
   - If you fail to run this step, the CI test
     `ensure_web_assets_built_test.dart` will fail because `assetInputsHash`
     will no longer match the source files on disk.

## Code Generation (`build_runner`)

- `pubviz` uses `build_cli` (for `lib/src/options.dart`) and `build_version`
  (for `lib/src/version.dart`).
- The `dart tool/update_assets.dart` script invokes `build_runner build` under
  the hood, so running it will also safely update `options.g.dart` and
  `version.dart` if their inputs changed.

## Code Hygiene

- Use `dart format .` after making Dart file changes to maintain spacing/styling
  rules.
- Validate your work with `dart test` (or `dart test -P presubmit`) to ensure
  your modifications didn't break functionality.

## Testing Best Practices

- **Programmatic Sandboxing**: When adding test suites for edge cases that
  require synthetic setup files (e.g., `pubspec.yaml`, `outdated.json`), use
  **`package:test_descriptor`** (`d.dir()`) to build isolated filesystems
  on-the-fly within `d.sandbox`. If many tests need the same setup, you can do
  this in `setUp()`. This guarantees absolute parallel isolated pass-rates and
  avoids workspace git-littering artifacts.

## Debugging and Experimenting

- When debugging or experimenting with the CLI, prefer using the `-a serve` or
  `--action serve` command instead of the default `open` action. The default
  action opens a browser window, which can be annoying during development.
