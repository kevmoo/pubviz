# Pubviz AI Agent Instructions

These instructions help guide AI agents when making changes to this repository.

## Web Assets Workflow (`_example_src` vs `lib/assets`)

The `pubviz` application includes a compiled web frontend that is bundled
directly into the Dart package. It is critical to understand the distinction
between the source files and the compiled outputs:

1. **Source of Truth (`_example_src/`)**:
   - All web application source code (HTML, CSS, Dart) lives in the
     `_example_src` directory.
   - **Make all web-related UI or logic edits here.** Do NOT manually edit
     files in `lib/assets/`.

2. **Compiled Output (`lib/assets/`)**:
   - This directory contains the final generated web artifacts (Compiled JS,
     WASM, CSS, copied HTML, etc.) ensuring offline functionality.
   - It also contains `build_inputs.json`, which tracks the `SHA-256` hashes
     of the input files (`_example_src`, `lib`, `build.yaml`, `pubspec.yaml`)
     to ensure the cache isn't stale.

3. **Rebuilding Assets**:
   - Whenever you modify *anything* in `_example_src/`, `lib/`, `build.yaml`, 
     or `pubspec.yaml`, you **MUST** run the following command to recompile
     the assets and sync them to `lib/assets/`:
     ```bash
     dart tool/update_assets.dart
     ```
   - If you fail to run this step, the CI test
     `ensure_web_assets_built_test.dart` will fail because the
     `build_inputs.json` hash will no longer match the source files on disk,
     or the manual static byte checks will fail.

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

- **Programmatic Sandboxing**: 
  When adding test suites for edge cases that require synthetic setup files 
  (e.g., `pubspec.yaml`, `outdated.json`), 
  use **`package:test_descriptor`** (`d.dir()`) 
  inside `setUpAll()` to build isolated filesystems on-the-fly within 
  `d.sandbox`. This guarantees absolute parallel isolated pass-rates and avoids 
  workspace git-littering artifacts.
