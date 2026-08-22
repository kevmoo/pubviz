import 'viz_package.dart';

String formatNodeLabel(
  VizPackage pkg, {
  required bool isWorkspace,
  required bool isRoot,
  required String lineBreak,
}) {
  var label = pkg.name;
  if (isWorkspace && isRoot) {
    label = '⚙️ $label';
  }
  if (pkg.version != null) {
    label = '$label$lineBreak${pkg.version}';
  }
  return label;
}
