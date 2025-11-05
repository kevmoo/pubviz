import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:string_scanner/string_scanner.dart';

class DepsList {
  static final _sdkLine = RegExp(r'(\w+) SDK (.+)\n');

  final Map<String, Version> sdks;
  final Map<String, DepsPackageEntry> packages;
  final Map<VersionedEntry, Map<String, VersionConstraint>>
  transitiveDependencies;

  DepsList._(this.sdks, this.packages, {required this.transitiveDependencies}) {
    for (var entry in packages.values) {
      entry._parent = this;
    }
  }

  factory DepsList.parse(String input) {
    final scanner = StringScanner(input);

    final sdks = <String, Version>{};

    void scanSdk() {
      scanner.expect(_sdkLine, name: 'SDK');
      final entry = VersionedEntry.fromMatch(scanner.lastMatch!);
      assert(!sdks.containsKey(entry.name));
      sdks[entry.name] = entry.version;
    }

    do {
      scanSdk();
    } while (scanner.matches(_sdkLine));

    final pkgs = <String, DepsPackageEntry>{};
    while (scanner.matches(_packageLine)) {
      final entry = DepsPackageEntry._parse(scanner);
      pkgs[entry.name] = entry;
    }

    final section = scanner.matches(_transitiveDepsHeaderLine)
        ? _scanSection(
            scanner,
            headerPattern: _transitiveDepsHeaderLine,
          ).entries
        : <VersionedEntry, Map<String, VersionConstraint>>{};

    return DepsList._(sdks, pkgs, transitiveDependencies: section);
  }

  Map<String, dynamic> toJson() => {
    'sdks': sdks,
    'packages': packages,
    'transitiveDependencies': transitiveDependencies.map(
      (k, v) => MapEntry(k.toString(), v),
    ),
  };
}

class DepsPackageEntry extends VersionedEntry {
  static final _emptyLine = RegExp(r'\n');

  final Map<String, Map<VersionedEntry, Map<String, VersionConstraint>>>
  sections;

  late final DepsList _parent;

  Map<VersionedEntry, Map<String, VersionConstraint>> get allEntries =>
      CombinedMapView([
        ..._parent.packages.values.expand((e) => e.sections.values),
        _parent.transitiveDependencies,
      ]);

  DepsPackageEntry._(super.entry, this.sections) : super.copy();

  factory DepsPackageEntry._parse(StringScanner scanner) {
    scanner.expect(_packageLine, name: 'Source package');

    final sourcePackage = VersionedEntry.fromMatch(scanner.lastMatch!);

    final sections =
        <String, Map<VersionedEntry, Map<String, VersionConstraint>>>{};

    while (scanner.scan(_emptyLine)) {
      if (!scanner.matches(_sectionHeaderLine)) {
        break;
      }

      final section = _scanSection(scanner, headerPattern: _sectionHeaderLine);
      sections[section.name] = section.entries;
    }

    return DepsPackageEntry._(sourcePackage, sections);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'version': version.toString(),
    'sections': {
      for (var section in sections.entries)
        section.key: {
          for (var usage in section.value.entries)
            usage.key.toString(): {
              for (var dep in usage.value.entries)
                dep.key: dep.value.toString(),
            },
        },
    },
  };
}

/// A regular expression matching a Dart identifier.
///
/// This also matches a package name, since they must be Dart identifiers.
const _identifierRegExp = r'[a-zA-Z_]\w*';

/// A regular expression matching allowed package names.
///
/// This allows dot-separated valid Dart identifiers. The dots are there for
/// compatibility with Google's internal Dart packages, but they may not be used
/// when publishing a package to pub.dev.
const _pkgName = '$_identifierRegExp(?:\\.$_identifierRegExp)*';

final _sectionHeaderLine = RegExp(
  r'(dependencies|dev dependencies|dependency overrides):\n',
);
final _transitiveDepsHeaderLine = RegExp(r'(transitive dependencies):\n');
final _packageLine = RegExp('($_pkgName) (\\d.+)\n');
final _usageLine = RegExp('- ($_pkgName) (.+)\n');
final _depLine = RegExp('  - ($_pkgName) (.+)\n');

({String name, Map<VersionedEntry, Map<String, VersionConstraint>> entries})
_scanSection(StringScanner scanner, {required Pattern headerPattern}) {
  scanner.expect(headerPattern, name: 'section header');
  final header = scanner.lastMatch![1]!;

  final entries = <VersionedEntry, Map<String, VersionConstraint>>{};

  void scanUsage() {
    scanner.expect(_usageLine, name: 'dependency');
    final entry = VersionedEntry.fromMatch(scanner.lastMatch!);
    assert(!entries.containsKey(entry));

    final deps = entries[entry] = {};

    while (scanner.scan(_depLine)) {
      deps[scanner.lastMatch![1]!] = VersionConstraint.parse(
        scanner.lastMatch![2]!,
      );
    }
  }

  do {
    scanUsage();
  } while (scanner.matches(_usageLine));

  return (name: header, entries: entries);
}

class VersionedEntry {
  final String name;
  final Version version;

  VersionedEntry(this.name, this.version);

  VersionedEntry.copy(VersionedEntry other)
    : name = other.name,
      version = other.version;

  factory VersionedEntry.fromMatch(Match match) =>
      VersionedEntry(match[1]!, Version.parse(match[2]!));

  @override
  String toString() => '$name @ $version';

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is VersionedEntry && name == other.name;
}
