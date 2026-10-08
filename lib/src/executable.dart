import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:io/ansi.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'assets.g.dart';
import 'dot.dart';
import 'mermaid.dart';
import 'options.dart';
import 'pub_data_service.dart';
import 'published_package.dart';
import 'root_builder.dart';
import 'terminate.dart';
import 'update_order.dart';
import 'viz_root.dart';

Future<void> run(Options options) async {
  Directory? tempDir;
  String effectivePath;
  String? packageName;

  if (options.package case final targetPackage?) {
    (directory: tempDir, packageName: packageName) =
        await setupPublishedPackageProject(targetPackage);
    effectivePath = tempDir.path;
  } else {
    effectivePath = _resolveLocalPath(options.rest);
  }
  try {
    final service = PubDataService(effectivePath);

    final pubspec = service.rootPubspec();
    final includeWorkspace =
        options.workspace ??
        (pubspec.workspace != null || pubspec.resolution == 'workspace');

    final VizRoot vp;
    if (options.package != null) {
      final packages = await service.getReferencedPackages(
        options.flagOutdated,
        options.directDependencies ?? false,
        options.productionDependencies,
        includeWorkspace: includeWorkspace,
      );
      packages.remove(pubspec.name);

      vp = VizRoot.assemble(
        packageName!,
        packages,
        flagOutdated: options.flagOutdated,
        ignorePackages: options.ignorePackages,
        isWorkspace: includeWorkspace,
      );
    } else {
      vp = await service.vizRoot(
        flagOutdated: options.flagOutdated,
        ignorePackages: options.ignorePackages,
        directDependenciesOnly: options.directDependencies ?? false,
        productionDependenciesOnly: options.productionDependencies,
        includeWorkspace: includeWorkspace,
      );
    }
    final filteredVp = vp.filter(
      excludeDev: options.filters.contains(filterHideDev),
      onlyOutdated: options.filters.contains(filterOutdated),
      onlyWorkspace: options.filters.contains(filterWorkspace),
      hideIsolated: options.filters.contains(filterHideIsolated),
      ignorePackages: options.ignorePackages,
    );
    if (options.flagOutdated) {
      _printUpdateOrder(filteredVp);
    }
    switch (options.action) {
      case Action.print:
        print(filteredVp.toDot(ignorePackages: options.ignorePackages));
      case Action.printMermaid:
        print(filteredVp.toMermaid(ignorePackages: options.ignorePackages));
      case Action.open:
      case Action.serve:
        await _createOrOpen(filteredVp, options);
    }
  } finally {
    if (tempDir != null) {
      stderr.writeln('Cleaning up temporary directory...');
      tempDir.deleteSync(recursive: true);
    }
  }
}

String _resolveLocalPath(List<String> rest) {
  if (rest.length > 1) {
    throw UsageException(
      'Only one argument is allowed. You provided ${rest.length}.',
    );
  }
  final effectivePath = rest.isEmpty ? p.current : rest.first;

  if (!FileSystemEntity.isDirectorySync(effectivePath)) {
    throw UsageException(
      'The provided path does not exist or is not a directory: '
      '$effectivePath',
    );
  }

  final yamlPath = p.join(effectivePath, 'pubspec.yaml');
  if (!FileSystemEntity.isFileSync(yamlPath)) {
    throw UsageException(
      'Could not find a pubspec.yaml in the target path.: $effectivePath',
    );
  }

  return effectivePath;
}

void _printUpdateOrder(VizRoot root) {
  final updateOrder = computeUpdateOrder(root);
  if (updateOrder.isEmpty) return;

  stderr
    ..writeln()
    ..writeln(styleBold.wrap('Outdated package update order:'));
  for (final pkg in updateOrder) {
    final hasNewer = switch ((pkg.latestVersion, pkg.version)) {
      (final latest?, final current?) => latest > current,
      _ => false,
    };
    final suffix = hasNewer ? ' *' : '';
    stderr.writeln('  ${pkg.name}$suffix');
  }
  stderr
    ..writeln('\n(*) Newer version available')
    ..writeln();
}

Future<void> _createOrOpen(VizRoot root, Options options) async {
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
      .add(_embeddedAssetHandler())
      .handler;

  final server = await io.serve(handler, InternetAddress.loopbackIPv4, 0);
  var serverUrl = 'http://localhost:${server.port}/';
  if (options.filters.isNotEmpty) {
    serverUrl += '#/filters=${options.filters.join(',')}';
  }
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

/// Return a string that can be used as a JavaScript module exporting the
/// viz data.
@internal
String vizDataString(VizRoot root) {
  const encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(root.toJson());
  return 'export const vizDataString = JSON.stringify($jsonString);\n';
}

Handler _embeddedAssetHandler() {
  final cache = <String, Uint8List>{};
  return (Request request) {
    var path = request.url.path;
    if (path.isEmpty || path == '/') {
      path = 'index.html';
    }
    var compressedBytes = cache[path];
    if (compressedBytes == null) {
      final base64Content = embeddedAssets[path];
      if (base64Content == null) {
        return Response.notFound('Not found');
      }
      compressedBytes = cache[path] = base64Decode(base64Content);
    }
    final mimeType = _mimeTypeFor(path);
    final acceptEncoding = request.headers['accept-encoding'] ?? '';
    if (acceptEncoding.contains('gzip')) {
      return Response.ok(
        compressedBytes,
        headers: {'content-encoding': 'gzip', 'content-type': ?mimeType},
      );
    }
    final decompressed = gzip.decode(compressedBytes);
    return Response.ok(decompressed, headers: {'content-type': ?mimeType});
  };
}

String? _mimeTypeFor(String path) {
  final ext = p.extension(path).toLowerCase();
  return switch (ext) {
    '.html' => 'text/html',
    '.css' => 'text/css',
    '.js' || '.mjs' => 'text/javascript',
    '.wasm' => 'application/wasm',
    '.json' || '.map' => 'application/json',
    '.ico' => 'image/x-icon',
    _ => null,
  };
}
