import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:io/ansi.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

import 'dot.dart';
import 'options.dart';
import 'pub_data_service.dart';
import 'root_builder.dart';
import 'terminate.dart';
import 'update_order.dart';
import 'viz_root.dart';

Future<void> run(Options options) async {
  final path = _getPath(options.rest);
  final service = PubDataService(path);

  final pubspec = service.rootPubspec();
  final includeWorkspace =
      options.workspace ??
      (pubspec.workspace != null || pubspec.resolution == 'workspace');

  final vp = await service.vizRoot(
    flagOutdated: options.flagOutdated,
    ignorePackages: options.ignorePackages,
    directDependenciesOnly: options.directDependencies ?? false,
    productionDependenciesOnly: options.productionDependencies,
    includeWorkspace: includeWorkspace,
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
      await _createOrOpen(vp, options);
  }
}

String _getContentDot(VizRoot root, List<String> ignorePackages) =>
    root.toDot(ignorePackages: ignorePackages);

Future<void> _createOrOpen(VizRoot root, Options options) async {
  final assetsUri = await Isolate.resolvePackageUri(
    Uri.parse('package:pubviz/assets/'),
  );
  if (assetsUri == null) {
    throw const FileSystemException(
      'Could not resolve package:pubviz/assets/',
      'package:pubviz/assets/',
    );
  }

  final jsContent = vizDataString(root);

  final handler = Cascade()
      .add((Request request) {
        if (request.url.path == 'viz_data.js') {
          return Response.ok(
            jsContent,
            headers: {'content-type': 'text/javascript'},
          );
        }
        return Response.notFound('');
      })
      .add(
        createStaticHandler(
          assetsUri.toFilePath(),
          defaultDocument: 'index.html',
        ),
      )
      .handler;

  final server = await io.serve(handler, InternetAddress.loopbackIPv4, 0);
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
      print("We don't know how to open a file in ${Platform.operatingSystem}");
      exitCode = 1;
      return;
    }
    await Process.run(openCommand, [serverUrl]);
  }

  print('Press "q" (or "Q") or Ctrl+C to stop.');
  await waitForTerminate();
  await server.close(force: true);
}

void _printContent(VizRoot root, List<String> ignorePackages) {
  final content = _getContentDot(root, ignorePackages);
  print(content);
}

/// Return a string that can be used as a JavaScript module exporting the
/// viz data.
@internal
String vizDataString(VizRoot root) {
  const encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(root.toJson());
  return 'export const vizDataString = JSON.stringify($jsonString);\n';
}

String _getPath(List<String> args) {
  if (args.length > 1) {
    throw UsageException(
      'Only one argument is allowed. You provided ${args.length}.',
    );
  }

  final path = args.isEmpty ? p.current : args.first;

  if (!FileSystemEntity.isDirectorySync(path)) {
    throw UsageException(
      'The provided path does not exist or is not a directory: $path',
    );
  }

  final yamlPath = p.join(path, 'pubspec.yaml');

  if (!FileSystemEntity.isFileSync(yamlPath)) {
    throw UsageException(
      'Could not find a pubspec.yaml in the target path: $yamlPath',
    );
  }

  return path;
}

class UsageException implements Exception {
  final String message;

  UsageException(this.message);

  @override
  String toString() => message;
}
