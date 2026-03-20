// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';

/// Returns a [Future] that completes when the process receives a
/// [ProcessSignal] requesting a shutdown, or when 'q'/'Q' is pressed.
///
/// [ProcessSignal.sigint] is listened to on all platforms.
///
/// [ProcessSignal.sigterm] is listened to on all platforms except Windows.
Future<void> waitForTerminate() {
  final completer = Completer<bool>.sync();

  // sigIntSub is copied below to avoid a race condition - ignoring this lint
  // ignore: cancel_subscriptions
  StreamSubscription<ProcessSignal>? sigIntSub, sigTermSub;
  StreamSubscription<List<int>>? stdinSub;

  Future<void> signalHandler([ProcessSignal? signal]) async {
    if (signal != null) {
      print('\nReceived signal $signal - closing');
    } else {
      print('\nQuit requested - closing');
    }

    final subCopy = sigIntSub;
    if (subCopy != null) {
      sigIntSub = null;
      await subCopy.cancel();
      if (sigTermSub != null) {
        await sigTermSub!.cancel();
        sigTermSub = null;
      }
      if (stdinSub != null) {
        if (stdin.hasTerminal) {
          try {
            stdin.lineMode = true;
            stdin.echoMode = true;
          } catch (_) {
            // Contexts like some CI or debuggers may report hasTerminal = true
            // but fail when these properties are modified.
          }
        }
        await stdinSub!.cancel();
        stdinSub = null;
      }
      completer.complete(true);
    }
  }

  sigIntSub = ProcessSignal.sigint.watch().listen(signalHandler);

  // SIGTERM is not supported on Windows. Attempting to register a SIGTERM
  // handler raises an exception.
  if (!Platform.isWindows) {
    sigTermSub = ProcessSignal.sigterm.watch().listen(signalHandler);
  }

  try {
    if (stdin.hasTerminal) {
      stdin.lineMode = false;
      stdin.echoMode = false;
    }
    stdinSub = stdin.listen((event) {
      if (event.contains(113) || event.contains(81)) {
        // 'q' or 'Q'
        signalHandler();
      }
    });
  } catch (_) {
    // Ignore if terminal modifications fail.
  }

  return completer.future;
}
