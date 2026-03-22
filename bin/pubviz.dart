#!/usr/bin/env dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dhttpd/dhttpd.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as p;
import 'package:pubviz/pubviz.dart';
import 'package:pubviz/src/options.dart';
import 'package:pubviz/src/pub_data_service.dart';
import 'package:pubviz/src/terminate.dart';
import 'package:pubviz/src/update_order.dart';
import 'package:pubviz/src/version.dart';
import 'package:pubviz/viz/dot.dart' as dot;
import 'package:stack_trace/stack_trace.dart';

Future<void> main(List<String> args) async {
  await overrideAnsiOutput(stderr.supportsAnsiEscapes, () async {
    await _main(args);
  });
}

Future<void> _main(List<String> args) async {
  Options options;
  try {
    options = parseOptions(args);
  } on FormatException catch (e) {
    print(red.wrap(e.message));
    print('');
    _printUsage();
    exitCode = ExitCode.usage.code;
    return;
  }

  if (options.help) {
    _printUsage();
    return;
  }

  if (options.version) {
    print(packageVersion);
    return;
  }

  String path;
  try {
    path = _getPath(options.rest);
    // ignore: avoid_catching_errors
  } on StateError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
    return;
  }

  await Chain.capture(
    () async {
      final service = PubDataService(path);

      if (!options.workspace && service.rootPubspec().workspace != null) {
        stderr.writeln(
          yellow.wrap(
            'This package is a workspace root. '
            'To visualize all packages in the workspace, use the --workspace '
            'flag.',
          ),
        );
      }

      final vp = await VizRoot.forDirectory(
        service,
        flagOutdated: options.flagOutdated,
        ignorePackages: options.ignorePackages,
        directDependenciesOnly: options.directDependencies ?? false,
        productionDependenciesOnly: options.productionDependencies,
        includeWorkspace: options.workspace,
      );
      if (options.flagOutdated) {
        final updateOrder = computeUpdateOrder(vp);
        if (updateOrder.isNotEmpty) {
          stderr
            ..writeln()
            ..writeln(styleBold.wrap('Outdated package update order:'));
          for (final pkg in updateOrder) {
            stderr.writeln('  ${pkg.name}');
          }
          stderr.writeln();
        }
      }
      switch (options.action) {
        case Action.print:
          _printContent(vp, options.ignorePackages);
        case Action.open:
        case Action.serve:
        case Action.create:
          await _createOrOpen(vp, options);
      }
    },
    onError: (error, Chain chain) {
      stderr
        ..writeln(error)
        ..writeln(chain.terse);
      exitCode = 1;
    },
  );
}

String _indent(String input) =>
    LineSplitter.split(input).map((l) => '  $l'.trimRight()).join('\n');

void _printUsage() {
  print('''Usage: pubviz [<args>] [<package path>]

${styleBold.wrap('Arguments:')}
${_indent(parser.usage)}

If <package path> is omitted, the current directory is used.''');
}

String _getContentDot(VizRoot root, List<String> ignorePackages) =>
    dot.toDot(root, ignorePackages: ignorePackages);

Future<String> _getContentHtml(
  VizRoot root,
  List<String> ignorePackages,
) async {
  final indexUri = await Isolate.resolvePackageUri(
    Uri.parse('package:pubviz/assets/index.html'),
  );
  if (indexUri == null) {
    throw StateError('Could not resolve package:pubviz/assets/index.html');
  }
  final htmlTemplate = await File.fromUri(indexUri).readAsString();
  return dot.toDotHtml(htmlTemplate, root, ignorePackages: ignorePackages);
}

Future<void> _prepareHtmlAssets(Directory targetDir) async {
  final assetsUri = await Isolate.resolvePackageUri(
    Uri.parse('package:pubviz/assets/'),
  );
  if (assetsUri == null) {
    throw StateError('Could not resolve package:pubviz/assets/');
  }
  final assetsDir = Directory.fromUri(assetsUri);

  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  void copyDir(Directory source, Directory destination) {
    for (var entity in source.listSync()) {
      if (entity is Directory) {
        final newDir = Directory(
          p.join(destination.path, p.basename(entity.path)),
        )..createSync();
        copyDir(entity, newDir);
      } else if (entity is File) {
        if (p.basename(entity.path) == 'index.html') continue;
        entity.copySync(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }

  copyDir(assetsDir, targetDir);
}

Future<void> _createOrOpen(VizRoot root, Options options) async {
  final name = root.root.name;

  final isTempDir = options.outDir == null;
  Directory targetDir;
  if (!isTempDir) {
    targetDir = Directory(options.outDir!);
    if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
  } else {
    targetDir = await Directory.systemTemp.createTemp('pubviz_${name}_');
  }

  await _prepareHtmlAssets(targetDir);

  final filePath = p.join(targetDir.path, 'index.html');

  var file = File(filePath);
  file = await file.create();

  final content = await _getContentHtml(root, options.ignorePackages);
  await file.writeAsString(content, flush: true);

  print('File generated: $filePath');

  if (options.action == Action.serve || options.action == Action.open) {
    final server = await Dhttpd.start(
      path: targetDir.path,
      port: 0,
      quiet: true,
    );
    final serverUrl = 'http://localhost:${server.port}/';
    print('Serving pubviz on $serverUrl');

    if (options.action == Action.open) {
      String openCommand;
      if (Platform.isMacOS) {
        openCommand = 'open';
      } else if (Platform.isLinux) {
        openCommand = 'xdg-open';
      } else if (Platform.isWindows) {
        openCommand = 'explorer';
      } else {
        print(
          "We don't know how to open a file in ${Platform.operatingSystem}",
        );
        exitCode = 1;
        return;
      }
      await Process.run(openCommand, [serverUrl]);
    }

    print('Press "q" (or "Q") or Ctrl+C to stop.');
    await waitForTerminate();
    await server.destroy();

    if (isTempDir) {
      targetDir.deleteSync(recursive: true);
      print('Deleted temp directory: ${targetDir.path}');
    }
  }
}

void _printContent(VizRoot root, List<String> ignorePackages) {
  final content = _getContentDot(root, ignorePackages);
  print(content);
}

String _getPath(List<String> args) {
  if (args.length > 1) {
    throw StateError(
      'Only one argument is allowed. You provided ${args.length}.',
    );
  }

  final path = args.isEmpty ? p.current : args.first;

  if (!FileSystemEntity.isDirectorySync(path)) {
    throw StateError(
      'The provided path does not exist or is not a directory: $path',
    );
  }

  final yamlPath = p.join(path, 'pubspec.yaml');

  if (!FileSystemEntity.isFileSync(yamlPath)) {
    throw StateError(
      'Could not find a pubspec.yaml in the target path.: $path',
    );
  }

  return path;
}
