#!/bin/bash

# Fast fail the script on failures.
set -e

dart --checked test/viz_test.dart

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  pub global run dart_coveralls report \
    --exclude-test-files \
    test/viz_test.dart
fi
