library pubviz.dependency;

import 'package:pub_semver/pub_semver.dart';

class Dependency implements Comparable<Dependency> {
  final String name;
  final VersionConstraint versionConstraint;
  final bool isDevDependency;

  bool _includesLatest;

  bool get includesLatest => _includesLatest;

  void set includesLatest(bool value) {
    assert(_includesLatest == null);
    assert(value != null);
    _includesLatest = value;
  }

  Dependency._(this.name, String versionConstraint, this.isDevDependency)
      : this.versionConstraint = _parseOrNull(versionConstraint);

  static Set<Dependency> getDependencies(Map<String, dynamic> yaml) {
    var deps = new Set<Dependency>();

    _populateFromSection(yaml['dependencies'], deps, false);
    _populateFromSection(yaml['dev_dependencies'], deps, true);

    return deps;
  }

  static void _populateFromSection(
      Map<String, dynamic> yaml, Set<Dependency> value, bool isDev) {
    if (yaml != null) {
      yaml.forEach((String key, constraint) {
        if (constraint == null) {
          constraint = '';
        } else if (constraint is Map) {
          constraint = constraint.toString();
        }

        var dep = new Dependency._(key, constraint, isDev);
        assert(!value.contains(dep));

        value.add(dep);
      });
    }
  }

  bool operator ==(other) => other is Dependency && other.name == name;

  int get hashcode => name.hashCode;

  int compareTo(Dependency other) {
    if (other.isDevDependency == isDevDependency) {
      return name.compareTo(other.name);
    } else if (isDevDependency) {
      return 1;
    } else {
      return -1;
    }
  }

  String toString() {
    var devStr = isDevDependency ? '(dev)' : '';
    return '$name$devStr $versionConstraint';
  }
}

VersionConstraint _parseOrNull(String input) {
  try {
    return new VersionConstraint.parse(input);
  } on FormatException catch (e) {
    return VersionConstraint.empty;
  }
}
