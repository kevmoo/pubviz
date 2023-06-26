import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:string_scanner/string_scanner.dart';

class DepsList extends VersionedEntry {
  static final _sdkLine = RegExp(r'(\w+) SDK (.+)\n');
  static final _sourcePackageLine = RegExp('($_pkgName) (.+)\n');
  static final _emptyLine = RegExp(r'\n');

  final Map<String, Version> sdks;
  final Map<String, Map<VersionedEntry, Map<String, VersionConstraint>>>
      sections;

  Map<VersionedEntry, Map<String, VersionConstraint>> get allEntries =>
      CombinedMapView(sections.values);

  DepsList._(
    super.entry,
    this.sdks,
    this.sections,
  ) : super.copy();

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

    scanner.expect(_sourcePackageLine, name: 'Source package');
    final sourcePackage = VersionedEntry.fromMatch(scanner.lastMatch!);

    final sections =
        <String, Map<VersionedEntry, Map<String, VersionConstraint>>>{};

    while (scanner.scan(_emptyLine)) {
      final section = _scanSection(scanner);
      sections[section.key] = section.value;
    }

    assert(scanner.isDone, '${scanner.position} of ${input.length}');

    return DepsList._(
      sourcePackage,
      sdks,
      sections,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version.toString(),
        'sdks': {
          for (var sdk in sdks.entries) sdk.key: sdk.value.toString(),
        },
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

final _sectionHeaderLine = RegExp(r'([a-zA-Z ]+):\n');
final _usageLine = RegExp('- ($_pkgName) (.+)\n');
final _depLine = RegExp('  - ($_pkgName) (.+)\n');

MapEntry<String, Map<VersionedEntry, Map<String, VersionConstraint>>>
    _scanSection(StringScanner scanner) {
  scanner.expect(_sectionHeaderLine, name: 'section header');
  final header = scanner.lastMatch![1]!;

  final entries = <VersionedEntry, Map<String, VersionConstraint>>{};

  void scanUsage() {
    scanner.expect(_usageLine, name: 'dependency');
    final entry = VersionedEntry.fromMatch(scanner.lastMatch!);
    assert(!entries.containsKey(entry));

    final deps = entries[entry] = {};

    while (scanner.scan(_depLine)) {
      deps[scanner.lastMatch![1]!] =
          VersionConstraint.parse(scanner.lastMatch![2]!);
    }
  }

  do {
    scanUsage();
  } while (scanner.matches(_usageLine));

  return MapEntry(header, entries);
}

class VersionedEntry {
  final String name;
  final Version version;

  VersionedEntry(this.name, this.version);

  VersionedEntry.copy(VersionedEntry other)
      : name = other.name,
        version = other.version;

  factory VersionedEntry.fromMatch(Match match) => VersionedEntry(
        match[1]!,
        Version.parse(match[2]!),
      );

  @override
  String toString() => '$name @ $version';

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is VersionedEntry && name == other.name;
}
