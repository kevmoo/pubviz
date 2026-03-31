import 'service.dart';
import 'viz_root.dart';

extension ServiceVizRootExt on Service {
  Future<VizRoot> vizRoot({
    bool flagOutdated = false,
    Iterable<String>? ignorePackages,
    bool directDependenciesOnly = false,
    bool productionDependenciesOnly = false,
    bool includeWorkspace = false,
  }) async {
    final rootPubspec = this.rootPubspec();

    final packages = await getReferencedPackages(
      flagOutdated,
      directDependenciesOnly,
      productionDependenciesOnly,
      includeWorkspace: includeWorkspace,
    );

    return VizRoot.assemble(
      rootPubspec.name,
      packages,
      flagOutdated: flagOutdated,
      ignorePackages: ignorePackages,
      isWorkspace: includeWorkspace,
    );
  }
}
