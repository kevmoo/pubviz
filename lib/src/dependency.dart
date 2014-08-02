library pubviz.dependency;

class Dependency implements Comparable<Dependency> {
  final String name;
  final String versionConstraint;
  final bool isDevDependency;

  Dependency._(this.name, this.versionConstraint, this.isDevDependency);

  static Set<Dependency> getDependencies(Map<String, dynamic> yaml) {
    var deps = new Set<Dependency>();

    _populateFromSection(yaml['dependencies'], deps, false);
    _populateFromSection(yaml['dev_dependencies'], deps, true);

    return deps;
  }

  static void _populateFromSection(Map<String, dynamic> yaml, Set<Dependency> value, bool isDev) {
    if(yaml != null) {
      yaml.forEach((String key, constraint) {
        if (constraint == null) {
          constraint = '';
        } else if (constraint is Map) {
          constraint = '??complex??';
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
