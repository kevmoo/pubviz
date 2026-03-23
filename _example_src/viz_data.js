export const vizDataString = JSON.stringify({
  "rootPackageName": "pubviz",
  "packages": {
    "_fe_analyzer_shared": {
      "name": "_fe_analyzer_shared",
      "version": "98.0.0",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.9.0",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "analyzer": {
      "name": "analyzer",
      "version": "12.0.0",
      "dependencies": [
        {
          "name": "_fe_analyzer_shared",
          "versionConstraint": "^98.0.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0",
          "isDevDependency": false
        },
        {
          "name": "convert",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.18.0",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "watcher",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "archive": {
      "name": "archive",
      "version": "4.0.9",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "posix",
          "versionConstraint": "^6.0.2",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "args": {
      "name": "args",
      "version": "2.7.0",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "async": {
      "name": "async",
      "version": "2.13.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "bazel_worker": {
      "name": "bazel_worker",
      "version": "1.1.5",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "protobuf",
          "versionConstraint": ">=5.0.0 <7.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "boolean_selector": {
      "name": "boolean_selector",
      "version": "2.1.2",
      "dependencies": [
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build": {
      "name": "build",
      "version": "4.0.5",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_cli": {
      "name": "build_cli",
      "version": "2.2.11",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=10.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "build",
          "versionConstraint": "^4.0.4",
          "isDevDependency": false
        },
        {
          "name": "build_cli_annotations",
          "versionConstraint": ">=2.1.1 <2.2.0",
          "isDevDependency": false
        },
        {
          "name": "build_config",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "source_gen",
          "versionConstraint": "^4.1.2",
          "isDevDependency": false
        },
        {
          "name": "source_helper",
          "versionConstraint": "^1.3.10",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.3",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_cli_annotations": {
      "name": "build_cli_annotations",
      "version": "2.1.1",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.6.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "build_config": {
      "name": "build_config",
      "version": "1.3.0",
      "dependencies": [
        {
          "name": "checked_yaml",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.8.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_daemon": {
      "name": "build_daemon",
      "version": "4.1.1",
      "dependencies": [
        {
          "name": "built_collection",
          "versionConstraint": "^5.0.0",
          "isDevDependency": false
        },
        {
          "name": "built_value",
          "versionConstraint": "^8.1.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.3",
          "isDevDependency": false
        },
        {
          "name": "http_multi_server",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_web_socket",
          "versionConstraint": ">=1.0.0 <4.0.0",
          "isDevDependency": false
        },
        {
          "name": "stream_transform",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "watcher",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.3.0 <4.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_modules": {
      "name": "build_modules",
      "version": "5.1.10",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=5.1.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "bazel_worker",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "build",
          "versionConstraint": ">=2.0.0 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "file",
          "versionConstraint": "^7.0.1",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "graphs",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.3.0",
          "isDevDependency": false
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "scratch_space",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        },
        {
          "name": "stream_transform",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "uuid",
          "versionConstraint": "^4.4.2",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_runner": {
      "name": "build_runner",
      "version": "2.13.1",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "args",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "build",
          "versionConstraint": "^4.0.0",
          "isDevDependency": false
        },
        {
          "name": "build_config",
          "versionConstraint": ">=1.3.0 <1.4.0",
          "isDevDependency": false
        },
        {
          "name": "build_daemon",
          "versionConstraint": "^4.0.0",
          "isDevDependency": false
        },
        {
          "name": "built_collection",
          "versionConstraint": "^5.1.1",
          "isDevDependency": false
        },
        {
          "name": "built_value",
          "versionConstraint": "^8.10.1",
          "isDevDependency": false
        },
        {
          "name": "code_builder",
          "versionConstraint": "^4.2.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "convert",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "dart_style",
          "versionConstraint": ">=2.3.7 <4.0.0",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "graphs",
          "versionConstraint": "^2.2.0",
          "isDevDependency": false
        },
        {
          "name": "http_multi_server",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.8.1",
          "isDevDependency": false
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        },
        {
          "name": "mime",
          "versionConstraint": ">=1.0.0 <3.0.0",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_web_socket",
          "versionConstraint": ">=1.0.0 <4.0.0",
          "isDevDependency": false
        },
        {
          "name": "stream_transform",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "watcher",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.3.0 <4.0.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_verify": {
      "name": "build_verify",
      "version": "3.1.1",
      "dependencies": [
        {
          "name": "io",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "test",
          "versionConstraint": "^1.16.6",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_version": {
      "name": "build_version",
      "version": "2.1.3",
      "dependencies": [
        {
          "name": "build",
          "versionConstraint": ">=3.0.0 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "build_config",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "build_web_compilers": {
      "name": "build_web_compilers",
      "version": "4.4.16",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=5.1.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "archive",
          "versionConstraint": ">=3.0.0 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "bazel_worker",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "build",
          "versionConstraint": ">=2.0.0 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "build_modules",
          "versionConstraint": "^5.1.7",
          "isDevDependency": false
        },
        {
          "name": "build_runner",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        },
        {
          "name": "scratch_space",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "built_collection": {
      "name": "built_collection",
      "version": "5.1.1",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "built_value": {
      "name": "built_value",
      "version": "8.12.4",
      "dependencies": [
        {
          "name": "built_collection",
          "versionConstraint": "^5.0.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "fixnum",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "checked_yaml": {
      "name": "checked_yaml",
      "version": "2.0.4",
      "dependencies": [
        {
          "name": "json_annotation",
          "versionConstraint": "^4.3.0",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "cli_config": {
      "name": "cli_config",
      "version": "0.2.0",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.4.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.1",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "code_builder": {
      "name": "code_builder",
      "version": "4.11.1",
      "dependencies": [
        {
          "name": "built_collection",
          "versionConstraint": "^5.1.1",
          "isDevDependency": false
        },
        {
          "name": "built_value",
          "versionConstraint": "^8.10.1",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0",
          "isDevDependency": false
        },
        {
          "name": "matcher",
          "versionConstraint": "^0.12.16+1",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "collection": {
      "name": "collection",
      "version": "1.19.1",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "convert": {
      "name": "convert",
      "version": "3.1.2",
      "dependencies": [
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "coverage": {
      "name": "coverage",
      "version": "1.15.0",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "cli_config",
          "versionConstraint": "^0.2.0",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.1.2",
          "isDevDependency": false
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.0.2",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "vm_service",
          "versionConstraint": ">=12.0.0 <16.0.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.3",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "crypto": {
      "name": "crypto",
      "version": "3.0.7",
      "dependencies": [
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "dart_flutter_team_lints": {
      "name": "dart_flutter_team_lints",
      "version": "3.5.2",
      "dependencies": [
        {
          "name": "lints",
          "versionConstraint": "^6.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "dart_style": {
      "name": "dart_style",
      "version": "3.1.8",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": "^12.0.0",
          "isDevDependency": false
        },
        {
          "name": "args",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.2",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "dhttpd": {
      "name": "dhttpd",
      "version": "4.3.0",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "build_cli_annotations",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_static",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "ffi": {
      "name": "ffi",
      "version": "2.2.0",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "file": {
      "name": "file",
      "version": "7.0.1",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.9.1",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.3",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "fixnum": {
      "name": "fixnum",
      "version": "1.1.1",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "frontend_server_client": {
      "name": "frontend_server_client",
      "version": "4.0.0",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "glob": {
      "name": "glob",
      "version": "2.1.3",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "file",
          "versionConstraint": ">=6.1.3 <8.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "graphs": {
      "name": "graphs",
      "version": "2.3.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "gviz": {
      "name": "gviz",
      "version": "0.4.2",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "http": {
      "name": "http",
      "version": "1.6.0",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        },
        {
          "name": "web",
          "versionConstraint": ">=0.5.0 <2.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "http_multi_server": {
      "name": "http_multi_server",
      "version": "3.2.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "http_parser": {
      "name": "http_parser",
      "version": "4.1.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.19.0",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        },
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "io": {
      "name": "io",
      "version": "1.0.5",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "json_annotation": {
      "name": "json_annotation",
      "version": "4.11.0",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "json_serializable": {
      "name": "json_serializable",
      "version": "6.13.1",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=10.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "async",
          "versionConstraint": "^2.10.0",
          "isDevDependency": false
        },
        {
          "name": "build",
          "versionConstraint": "^4.0.4",
          "isDevDependency": false
        },
        {
          "name": "build_config",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        },
        {
          "name": "dart_style",
          "versionConstraint": "^3.1.4",
          "isDevDependency": false
        },
        {
          "name": "json_annotation",
          "versionConstraint": ">=4.11.0 <4.12.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "source_gen",
          "versionConstraint": "^4.1.2",
          "isDevDependency": false
        },
        {
          "name": "source_helper",
          "versionConstraint": "^1.3.10",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "lints": {
      "name": "lints",
      "version": "6.1.0",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "logging": {
      "name": "logging",
      "version": "1.3.0",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "matcher": {
      "name": "matcher",
      "version": "0.12.19",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.10.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        },
        {
          "name": "test_api",
          "versionConstraint": ">=0.5.0 <0.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "meta": {
      "name": "meta",
      "version": "1.18.2",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "mime": {
      "name": "mime",
      "version": "2.0.0",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "node_preamble": {
      "name": "node_preamble",
      "version": "2.0.2",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "package_config": {
      "name": "package_config",
      "version": "2.2.0",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "path": {
      "name": "path",
      "version": "1.9.1",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "pool": {
      "name": "pool",
      "version": "1.5.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "posix": {
      "name": "posix",
      "version": "6.5.0",
      "dependencies": [
        {
          "name": "ffi",
          "versionConstraint": "^2.0.1",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.7.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.3",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "protobuf": {
      "name": "protobuf",
      "version": "6.0.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "fixnum",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.7.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "pub_semver": {
      "name": "pub_semver",
      "version": "2.2.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "pubspec_parse": {
      "name": "pubspec_parse",
      "version": "1.5.0",
      "dependencies": [
        {
          "name": "checked_yaml",
          "versionConstraint": "^2.0.1",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0",
          "isDevDependency": false
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.9.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "pubviz": {
      "name": "pubviz",
      "version": null,
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.6.0",
          "isDevDependency": false
        },
        {
          "name": "build_cli_annotations",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0",
          "isDevDependency": false
        },
        {
          "name": "dhttpd",
          "versionConstraint": "^4.3.0",
          "isDevDependency": false
        },
        {
          "name": "gviz",
          "versionConstraint": "^0.4.2",
          "isDevDependency": false
        },
        {
          "name": "http",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.11.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.18.2",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.0",
          "isDevDependency": false
        },
        {
          "name": "build_cli",
          "versionConstraint": "^2.2.1",
          "isDevDependency": true
        },
        {
          "name": "build_runner",
          "versionConstraint": "^2.13.1",
          "isDevDependency": true
        },
        {
          "name": "build_verify",
          "versionConstraint": "^3.0.0",
          "isDevDependency": true
        },
        {
          "name": "build_version",
          "versionConstraint": "^2.0.3",
          "isDevDependency": true
        },
        {
          "name": "build_web_compilers",
          "versionConstraint": "^4.2.4",
          "isDevDependency": true
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.7",
          "isDevDependency": true
        },
        {
          "name": "dart_flutter_team_lints",
          "versionConstraint": "^3.0.0",
          "isDevDependency": true
        },
        {
          "name": "json_serializable",
          "versionConstraint": "^6.13.1",
          "isDevDependency": true
        },
        {
          "name": "test",
          "versionConstraint": "^1.25.1",
          "isDevDependency": true
        },
        {
          "name": "test_descriptor",
          "versionConstraint": "^2.0.0",
          "isDevDependency": true
        },
        {
          "name": "test_process",
          "versionConstraint": "^2.0.0",
          "isDevDependency": true
        },
        {
          "name": "web",
          "versionConstraint": "^1.0.0",
          "isDevDependency": true
        }
      ],
      "isPrimary": true,
      "onlyDev": false,
      "latestVersion": null
    },
    "scratch_space": {
      "name": "scratch_space",
      "version": "1.2.0",
      "dependencies": [
        {
          "name": "build",
          "versionConstraint": ">=2.0.0 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "shelf": {
      "name": "shelf",
      "version": "1.4.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.1.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "shelf_packages_handler": {
      "name": "shelf_packages_handler",
      "version": "3.0.2",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_static",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "shelf_static": {
      "name": "shelf_static",
      "version": "1.1.3",
      "dependencies": [
        {
          "name": "convert",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.0.0",
          "isDevDependency": false
        },
        {
          "name": "mime",
          "versionConstraint": ">=1.0.0 <3.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.1.2",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "shelf_web_socket": {
      "name": "shelf_web_socket",
      "version": "3.0.0",
      "dependencies": [
        {
          "name": "shelf",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.0.0 <4.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "source_gen": {
      "name": "source_gen",
      "version": "4.2.2",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.1.1 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "async",
          "versionConstraint": "^2.10.0",
          "isDevDependency": false
        },
        {
          "name": "build",
          "versionConstraint": ">=3.0.2 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "dart_style",
          "versionConstraint": "^3.1.2",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0",
          "isDevDependency": false
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.2",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "source_helper": {
      "name": "source_helper",
      "version": "1.3.11",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=9.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "source_gen",
          "versionConstraint": "^4.1.1",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "source_map_stack_trace": {
      "name": "source_map_stack_trace",
      "version": "2.1.2",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "source_maps": {
      "name": "source_maps",
      "version": "0.10.13",
      "dependencies": [
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "source_span": {
      "name": "source_span",
      "version": "1.10.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "stack_trace": {
      "name": "stack_trace",
      "version": "1.12.1",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "stream_channel": {
      "name": "stream_channel",
      "version": "2.1.4",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "stream_transform": {
      "name": "stream_transform",
      "version": "2.1.1",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "string_scanner": {
      "name": "string_scanner",
      "version": "1.4.1",
      "dependencies": [
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "term_glyph": {
      "name": "term_glyph",
      "version": "1.2.2",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "test": {
      "name": "test",
      "version": "1.31.0",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "boolean_selector",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "coverage",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "http_multi_server",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "matcher",
          "versionConstraint": ">=0.12.16 <0.12.20",
          "isDevDependency": false
        },
        {
          "name": "node_preamble",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_packages_handler",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_static",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "shelf_web_socket",
          "versionConstraint": ">=1.0.0 <4.0.0",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "test_api",
          "versionConstraint": "0.7.11",
          "isDevDependency": false
        },
        {
          "name": "test_core",
          "versionConstraint": "0.6.17",
          "isDevDependency": false
        },
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.0.0 <4.0.0",
          "isDevDependency": false
        },
        {
          "name": "webkit_inspection_protocol",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "test_api": {
      "name": "test_api",
      "version": "0.7.11",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "boolean_selector",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "test_core": {
      "name": "test_core",
      "version": "0.6.17",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0",
          "isDevDependency": false
        },
        {
          "name": "args",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "boolean_selector",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "coverage",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "frontend_server_client",
          "versionConstraint": ">=3.2.0 <5.0.0",
          "isDevDependency": false
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0",
          "isDevDependency": false
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0",
          "isDevDependency": false
        },
        {
          "name": "source_map_stack_trace",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0",
          "isDevDependency": false
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "test_api",
          "versionConstraint": "0.7.11",
          "isDevDependency": false
        },
        {
          "name": "vm_service",
          "versionConstraint": ">=6.0.0 <16.0.0",
          "isDevDependency": false
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "test_descriptor": {
      "name": "test_descriptor",
      "version": "2.0.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        },
        {
          "name": "test",
          "versionConstraint": "^1.16.6",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "test_process": {
      "name": "test_process",
      "version": "2.1.1",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "test",
          "versionConstraint": "^1.16.6",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "typed_data": {
      "name": "typed_data",
      "version": "1.4.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "uuid": {
      "name": "uuid",
      "version": "4.5.3",
      "dependencies": [
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "fixnum",
          "versionConstraint": "^1.1.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "vm_service": {
      "name": "vm_service",
      "version": "15.0.2",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "watcher": {
      "name": "watcher",
      "version": "1.2.1",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "web": {
      "name": "web",
      "version": "1.1.1",
      "dependencies": [],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    },
    "web_socket": {
      "name": "web_socket",
      "version": "1.0.1",
      "dependencies": [
        {
          "name": "web",
          "versionConstraint": ">=0.5.0 <2.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "web_socket_channel": {
      "name": "web_socket_channel",
      "version": "3.0.3",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0",
          "isDevDependency": false
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0",
          "isDevDependency": false
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0",
          "isDevDependency": false
        },
        {
          "name": "web",
          "versionConstraint": ">=0.5.0 <2.0.0",
          "isDevDependency": false
        },
        {
          "name": "web_socket",
          "versionConstraint": ">=0.1.5 <2.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "webkit_inspection_protocol": {
      "name": "webkit_inspection_protocol",
      "version": "1.2.1",
      "dependencies": [
        {
          "name": "logging",
          "versionConstraint": "^1.0.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": true,
      "latestVersion": null
    },
    "yaml": {
      "name": "yaml",
      "version": "3.1.3",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0",
          "isDevDependency": false
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0",
          "isDevDependency": false
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.2.0",
          "isDevDependency": false
        }
      ],
      "isPrimary": false,
      "onlyDev": false,
      "latestVersion": null
    }
  }
});
