import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dhttpd/dhttpd.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;

import 'dot.dart';
import 'options.dart';
import 'pub_data_service.dart';
import 'root_builder.dart';
import 'terminate.dart';
import 'update_order.dart';
import 'viz_root.dart';

Future<void> run(Options options, String path) async {
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

  final vp = await service.vizRoot(
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
}

String _getContentDot(VizRoot root, List<String> ignorePackages) =>
    root.toDot(ignorePackages: ignorePackages);

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
  final jsContent =
      'export const vizDataString = '
      'JSON.stringify(${jsonEncode(root.toJson())});\n';
  File(p.join(targetDir.path, 'viz_data.js')).writeAsStringSync(jsContent);

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
