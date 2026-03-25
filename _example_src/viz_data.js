export const vizDataString = JSON.stringify({
  "rootPackageName": "pubviz",
  "packages": {
    "_fe_analyzer_shared": {
      "name": "_fe_analyzer_shared",
      "version": "98.0.0",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.9.0"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.10.0"
        }
      ]
    },
    "analyzer": {
      "name": "analyzer",
      "version": "12.0.0",
      "dependencies": [
        {
          "name": "_fe_analyzer_shared",
          "versionConstraint": "^98.0.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0"
        },
        {
          "name": "convert",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.18.0"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "watcher",
          "versionConstraint": "^1.1.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0"
        }
      ]
    },
    "archive": {
      "name": "archive",
      "version": "4.0.9",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "posix",
          "versionConstraint": "^6.0.2"
        }
      ]
    },
    "args": {
      "name": "args",
      "version": "2.7.0",
      "dependencies": [],
      "onlyDev": false
    },
    "async": {
      "name": "async",
      "version": "2.13.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0"
        }
      ],
      "onlyDev": false
    },
    "bazel_worker": {
      "name": "bazel_worker",
      "version": "1.1.5",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "protobuf",
          "versionConstraint": ">=5.0.0 <7.0.0"
        }
      ]
    },
    "boolean_selector": {
      "name": "boolean_selector",
      "version": "2.1.2",
      "dependencies": [
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0"
        }
      ]
    },
    "build": {
      "name": "build",
      "version": "4.0.5",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        }
      ]
    },
    "build_cli": {
      "name": "build_cli",
      "version": "2.2.11",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=10.0.0 <13.0.0"
        },
        {
          "name": "build",
          "versionConstraint": "^4.0.4"
        },
        {
          "name": "build_cli_annotations",
          "versionConstraint": ">=2.1.1 <2.2.0"
        },
        {
          "name": "build_config",
          "versionConstraint": "^1.2.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "source_gen",
          "versionConstraint": "^4.1.2"
        },
        {
          "name": "source_helper",
          "versionConstraint": "^1.3.10"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.3"
        }
      ]
    },
    "build_cli_annotations": {
      "name": "build_cli_annotations",
      "version": "2.1.1",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.6.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        }
      ],
      "onlyDev": false
    },
    "build_config": {
      "name": "build_config",
      "version": "1.3.0",
      "dependencies": [
        {
          "name": "checked_yaml",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.8.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.0.0"
        }
      ]
    },
    "build_daemon": {
      "name": "build_daemon",
      "version": "4.1.1",
      "dependencies": [
        {
          "name": "built_collection",
          "versionConstraint": "^5.0.0"
        },
        {
          "name": "built_value",
          "versionConstraint": "^8.1.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.3"
        },
        {
          "name": "http_multi_server",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0"
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "shelf_web_socket",
          "versionConstraint": ">=1.0.0 <4.0.0"
        },
        {
          "name": "stream_transform",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "watcher",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.3.0 <4.0.0"
        }
      ]
    },
    "build_modules": {
      "name": "build_modules",
      "version": "5.1.10",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=5.1.0 <13.0.0"
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "bazel_worker",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "build",
          "versionConstraint": ">=2.0.0 <5.0.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "file",
          "versionConstraint": "^7.0.1"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "graphs",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.3.0"
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "scratch_space",
          "versionConstraint": "^1.2.0"
        },
        {
          "name": "stream_transform",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "uuid",
          "versionConstraint": "^4.4.2"
        }
      ]
    },
    "build_runner": {
      "name": "build_runner",
      "version": "2.13.1",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0"
        },
        {
          "name": "args",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "build",
          "versionConstraint": "^4.0.0"
        },
        {
          "name": "build_config",
          "versionConstraint": ">=1.3.0 <1.4.0"
        },
        {
          "name": "build_daemon",
          "versionConstraint": "^4.0.0"
        },
        {
          "name": "built_collection",
          "versionConstraint": "^5.1.1"
        },
        {
          "name": "built_value",
          "versionConstraint": "^8.10.1"
        },
        {
          "name": "code_builder",
          "versionConstraint": "^4.2.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "convert",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "dart_style",
          "versionConstraint": ">=2.3.7 <4.0.0"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "graphs",
          "versionConstraint": "^2.2.0"
        },
        {
          "name": "http_multi_server",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.8.1"
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        },
        {
          "name": "mime",
          "versionConstraint": ">=1.0.0 <3.0.0"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "shelf_web_socket",
          "versionConstraint": ">=1.0.0 <4.0.0"
        },
        {
          "name": "stream_transform",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "watcher",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.3.0 <4.0.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0"
        }
      ]
    },
    "build_verify": {
      "name": "build_verify",
      "version": "3.1.1",
      "dependencies": [
        {
          "name": "io",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "test",
          "versionConstraint": "^1.16.6"
        }
      ]
    },
    "build_version": {
      "name": "build_version",
      "version": "2.1.3",
      "dependencies": [
        {
          "name": "build",
          "versionConstraint": ">=3.0.0 <5.0.0"
        },
        {
          "name": "build_config",
          "versionConstraint": "^1.1.0"
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.0.0"
        }
      ]
    },
    "build_web_compilers": {
      "name": "build_web_compilers",
      "version": "4.4.16",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=5.1.0 <13.0.0"
        },
        {
          "name": "archive",
          "versionConstraint": ">=3.0.0 <5.0.0"
        },
        {
          "name": "bazel_worker",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "build",
          "versionConstraint": ">=2.0.0 <5.0.0"
        },
        {
          "name": "build_modules",
          "versionConstraint": "^5.1.7"
        },
        {
          "name": "build_runner",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0"
        },
        {
          "name": "scratch_space",
          "versionConstraint": "^1.2.0"
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        }
      ]
    },
    "built_collection": {
      "name": "built_collection",
      "version": "5.1.1",
      "dependencies": []
    },
    "built_value": {
      "name": "built_value",
      "version": "8.12.4",
      "dependencies": [
        {
          "name": "built_collection",
          "versionConstraint": "^5.0.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "fixnum",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0"
        }
      ]
    },
    "checked_yaml": {
      "name": "checked_yaml",
      "version": "2.0.4",
      "dependencies": [
        {
          "name": "json_annotation",
          "versionConstraint": "^4.3.0"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0"
        }
      ],
      "onlyDev": false
    },
    "cli_config": {
      "name": "cli_config",
      "version": "0.2.0",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.4.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.1"
        }
      ]
    },
    "code_builder": {
      "name": "code_builder",
      "version": "4.11.1",
      "dependencies": [
        {
          "name": "built_collection",
          "versionConstraint": "^5.1.1"
        },
        {
          "name": "built_value",
          "versionConstraint": "^8.10.1"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0"
        },
        {
          "name": "matcher",
          "versionConstraint": "^0.12.16+1"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        }
      ]
    },
    "collection": {
      "name": "collection",
      "version": "1.19.1",
      "dependencies": [],
      "onlyDev": false
    },
    "convert": {
      "name": "convert",
      "version": "3.1.2",
      "dependencies": [
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0"
        }
      ],
      "onlyDev": false
    },
    "coverage": {
      "name": "coverage",
      "version": "1.15.0",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "cli_config",
          "versionConstraint": "^0.2.0"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.1.2"
        },
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.0.2"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "vm_service",
          "versionConstraint": ">=12.0.0 <16.0.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.3"
        }
      ]
    },
    "crypto": {
      "name": "crypto",
      "version": "3.0.7",
      "dependencies": [
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0"
        }
      ]
    },
    "dart_flutter_team_lints": {
      "name": "dart_flutter_team_lints",
      "version": "3.5.2",
      "dependencies": [
        {
          "name": "lints",
          "versionConstraint": "^6.0.0"
        }
      ]
    },
    "dart_style": {
      "name": "dart_style",
      "version": "3.1.8",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": "^12.0.0"
        },
        {
          "name": "args",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.2"
        }
      ]
    },
    "dhttpd": {
      "name": "dhttpd",
      "version": "4.3.0",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "build_cli_annotations",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "shelf_static",
          "versionConstraint": "^1.0.0"
        }
      ],
      "onlyDev": false
    },
    "ffi": {
      "name": "ffi",
      "version": "2.2.0",
      "dependencies": []
    },
    "file": {
      "name": "file",
      "version": "7.0.1",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.9.1"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.3"
        }
      ]
    },
    "fixnum": {
      "name": "fixnum",
      "version": "1.1.1",
      "dependencies": []
    },
    "frontend_server_client": {
      "name": "frontend_server_client",
      "version": "4.0.0",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        }
      ]
    },
    "glob": {
      "name": "glob",
      "version": "2.1.3",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "file",
          "versionConstraint": ">=6.1.3 <8.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0"
        }
      ]
    },
    "graphs": {
      "name": "graphs",
      "version": "2.3.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        }
      ]
    },
    "gviz": {
      "name": "gviz",
      "version": "0.4.2",
      "dependencies": [],
      "onlyDev": false
    },
    "http": {
      "name": "http",
      "version": "1.6.0",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0"
        },
        {
          "name": "web",
          "versionConstraint": ">=0.5.0 <2.0.0"
        }
      ],
      "onlyDev": false
    },
    "http_multi_server": {
      "name": "http_multi_server",
      "version": "3.2.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        }
      ]
    },
    "http_parser": {
      "name": "http_parser",
      "version": "4.1.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.19.0"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0"
        },
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0"
        }
      ],
      "onlyDev": false
    },
    "io": {
      "name": "io",
      "version": "1.0.5",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.3.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0"
        }
      ],
      "onlyDev": false
    },
    "json_annotation": {
      "name": "json_annotation",
      "version": "4.11.0",
      "dependencies": [
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        }
      ],
      "onlyDev": false
    },
    "json_serializable": {
      "name": "json_serializable",
      "version": "6.13.1",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=10.0.0 <13.0.0"
        },
        {
          "name": "async",
          "versionConstraint": "^2.10.0"
        },
        {
          "name": "build",
          "versionConstraint": "^4.0.4"
        },
        {
          "name": "build_config",
          "versionConstraint": "^1.2.0"
        },
        {
          "name": "dart_style",
          "versionConstraint": "^3.1.4"
        },
        {
          "name": "json_annotation",
          "versionConstraint": ">=4.11.0 <4.12.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "source_gen",
          "versionConstraint": "^4.1.2"
        },
        {
          "name": "source_helper",
          "versionConstraint": "^1.3.10"
        }
      ]
    },
    "lints": {
      "name": "lints",
      "version": "6.1.0",
      "dependencies": []
    },
    "logging": {
      "name": "logging",
      "version": "1.3.0",
      "dependencies": []
    },
    "matcher": {
      "name": "matcher",
      "version": "0.12.19",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.10.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0"
        },
        {
          "name": "test_api",
          "versionConstraint": ">=0.5.0 <0.8.0"
        }
      ]
    },
    "meta": {
      "name": "meta",
      "version": "1.18.2",
      "dependencies": [],
      "onlyDev": false
    },
    "mime": {
      "name": "mime",
      "version": "2.0.0",
      "dependencies": [],
      "onlyDev": false
    },
    "node_preamble": {
      "name": "node_preamble",
      "version": "2.0.2",
      "dependencies": []
    },
    "package_config": {
      "name": "package_config",
      "version": "2.2.0",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        }
      ]
    },
    "path": {
      "name": "path",
      "version": "1.9.1",
      "dependencies": [],
      "onlyDev": false
    },
    "pool": {
      "name": "pool",
      "version": "1.5.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        }
      ]
    },
    "posix": {
      "name": "posix",
      "version": "6.5.0",
      "dependencies": [
        {
          "name": "ffi",
          "versionConstraint": "^2.0.1"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.7.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.3"
        }
      ]
    },
    "protobuf": {
      "name": "protobuf",
      "version": "6.0.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "fixnum",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.7.0"
        }
      ]
    },
    "pub_semver": {
      "name": "pub_semver",
      "version": "2.2.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        }
      ],
      "onlyDev": false
    },
    "pubspec_parse": {
      "name": "pubspec_parse",
      "version": "1.5.0",
      "dependencies": [
        {
          "name": "checked_yaml",
          "versionConstraint": "^2.0.1"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0"
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.9.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0"
        }
      ],
      "onlyDev": false
    },
    "pubviz": {
      "name": "pubviz",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.6.0"
        },
        {
          "name": "build_cli_annotations",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.19.0"
        },
        {
          "name": "dhttpd",
          "versionConstraint": "^4.3.0"
        },
        {
          "name": "gviz",
          "versionConstraint": "^0.4.2"
        },
        {
          "name": "http",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "json_annotation",
          "versionConstraint": "^4.11.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.18.2"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "pubspec_parse",
          "versionConstraint": "^1.5.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.0"
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
      "onlyDev": false
    },
    "scratch_space": {
      "name": "scratch_space",
      "version": "1.2.0",
      "dependencies": [
        {
          "name": "build",
          "versionConstraint": ">=2.0.0 <5.0.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0"
        }
      ]
    },
    "shelf": {
      "name": "shelf",
      "version": "1.4.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.1.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0"
        }
      ],
      "onlyDev": false
    },
    "shelf_packages_handler": {
      "name": "shelf_packages_handler",
      "version": "3.0.2",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "shelf_static",
          "versionConstraint": "^1.0.0"
        }
      ]
    },
    "shelf_static": {
      "name": "shelf_static",
      "version": "1.1.3",
      "dependencies": [
        {
          "name": "convert",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.0.0"
        },
        {
          "name": "mime",
          "versionConstraint": ">=1.0.0 <3.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.1.2"
        }
      ],
      "onlyDev": false
    },
    "shelf_web_socket": {
      "name": "shelf_web_socket",
      "version": "3.0.0",
      "dependencies": [
        {
          "name": "shelf",
          "versionConstraint": "^1.1.0"
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.0.0 <4.0.0"
        }
      ]
    },
    "source_gen": {
      "name": "source_gen",
      "version": "4.2.2",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.1.1 <13.0.0"
        },
        {
          "name": "async",
          "versionConstraint": "^2.10.0"
        },
        {
          "name": "build",
          "versionConstraint": ">=3.0.2 <5.0.0"
        },
        {
          "name": "dart_style",
          "versionConstraint": "^3.1.2"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.9.0"
        },
        {
          "name": "pub_semver",
          "versionConstraint": "^2.1.4"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.1.2"
        }
      ]
    },
    "source_helper": {
      "name": "source_helper",
      "version": "1.3.11",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=9.0.0 <13.0.0"
        },
        {
          "name": "source_gen",
          "versionConstraint": "^4.1.1"
        }
      ]
    },
    "source_map_stack_trace": {
      "name": "source_map_stack_trace",
      "version": "2.1.2",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        }
      ]
    },
    "source_maps": {
      "name": "source_maps",
      "version": "0.10.13",
      "dependencies": [
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        }
      ]
    },
    "source_span": {
      "name": "source_span",
      "version": "1.10.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0"
        }
      ],
      "onlyDev": false
    },
    "stack_trace": {
      "name": "stack_trace",
      "version": "1.12.1",
      "dependencies": [
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        }
      ],
      "onlyDev": false
    },
    "stream_channel": {
      "name": "stream_channel",
      "version": "2.1.4",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        }
      ],
      "onlyDev": false
    },
    "stream_transform": {
      "name": "stream_transform",
      "version": "2.1.1",
      "dependencies": []
    },
    "string_scanner": {
      "name": "string_scanner",
      "version": "1.4.1",
      "dependencies": [
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        }
      ],
      "onlyDev": false
    },
    "term_glyph": {
      "name": "term_glyph",
      "version": "1.2.2",
      "dependencies": [],
      "onlyDev": false
    },
    "test": {
      "name": "test",
      "version": "1.31.0",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0"
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "boolean_selector",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "coverage",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "http_multi_server",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "matcher",
          "versionConstraint": ">=0.12.16 <0.12.20"
        },
        {
          "name": "node_preamble",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0"
        },
        {
          "name": "shelf",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "shelf_packages_handler",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "shelf_static",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "shelf_web_socket",
          "versionConstraint": ">=1.0.0 <4.0.0"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "test_api",
          "versionConstraint": "0.7.11"
        },
        {
          "name": "test_core",
          "versionConstraint": "0.6.17"
        },
        {
          "name": "typed_data",
          "versionConstraint": "^1.3.0"
        },
        {
          "name": "web_socket_channel",
          "versionConstraint": ">=2.0.0 <4.0.0"
        },
        {
          "name": "webkit_inspection_protocol",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0"
        }
      ]
    },
    "test_api": {
      "name": "test_api",
      "version": "0.7.11",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "boolean_selector",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.1.0"
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0"
        }
      ]
    },
    "test_core": {
      "name": "test_core",
      "version": "0.6.17",
      "dependencies": [
        {
          "name": "analyzer",
          "versionConstraint": ">=8.0.0 <13.0.0"
        },
        {
          "name": "args",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "boolean_selector",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "coverage",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "frontend_server_client",
          "versionConstraint": ">=3.2.0 <5.0.0"
        },
        {
          "name": "glob",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "io",
          "versionConstraint": "^1.0.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.16.0"
        },
        {
          "name": "package_config",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "pool",
          "versionConstraint": "^1.5.0"
        },
        {
          "name": "source_map_stack_trace",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "source_maps",
          "versionConstraint": "^0.10.10"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "stack_trace",
          "versionConstraint": "^1.10.0"
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "test_api",
          "versionConstraint": "0.7.11"
        },
        {
          "name": "vm_service",
          "versionConstraint": ">=6.0.0 <16.0.0"
        },
        {
          "name": "yaml",
          "versionConstraint": "^3.0.0"
        }
      ]
    },
    "test_descriptor": {
      "name": "test_descriptor",
      "version": "2.0.2",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "term_glyph",
          "versionConstraint": "^1.2.0"
        },
        {
          "name": "test",
          "versionConstraint": "^1.16.6"
        }
      ]
    },
    "test_process": {
      "name": "test_process",
      "version": "2.1.1",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "test",
          "versionConstraint": "^1.16.6"
        }
      ]
    },
    "typed_data": {
      "name": "typed_data",
      "version": "1.4.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        }
      ],
      "onlyDev": false
    },
    "uuid": {
      "name": "uuid",
      "version": "4.5.3",
      "dependencies": [
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "fixnum",
          "versionConstraint": "^1.1.0"
        }
      ]
    },
    "vm_service": {
      "name": "vm_service",
      "version": "15.0.2",
      "dependencies": []
    },
    "watcher": {
      "name": "watcher",
      "version": "1.2.1",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "path",
          "versionConstraint": "^1.8.0"
        }
      ]
    },
    "web": {
      "name": "web",
      "version": "1.1.1",
      "dependencies": [],
      "onlyDev": false
    },
    "web_socket": {
      "name": "web_socket",
      "version": "1.0.1",
      "dependencies": [
        {
          "name": "web",
          "versionConstraint": ">=0.5.0 <2.0.0"
        }
      ]
    },
    "web_socket_channel": {
      "name": "web_socket_channel",
      "version": "3.0.3",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        },
        {
          "name": "crypto",
          "versionConstraint": "^3.0.0"
        },
        {
          "name": "stream_channel",
          "versionConstraint": "^2.1.0"
        },
        {
          "name": "web",
          "versionConstraint": ">=0.5.0 <2.0.0"
        },
        {
          "name": "web_socket",
          "versionConstraint": ">=0.1.5 <2.0.0"
        }
      ]
    },
    "webkit_inspection_protocol": {
      "name": "webkit_inspection_protocol",
      "version": "1.2.1",
      "dependencies": [
        {
          "name": "logging",
          "versionConstraint": "^1.0.0"
        }
      ]
    },
    "yaml": {
      "name": "yaml",
      "version": "3.1.3",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "source_span",
          "versionConstraint": "^1.8.0"
        },
        {
          "name": "string_scanner",
          "versionConstraint": "^1.2.0"
        }
      ],
      "onlyDev": false
    }
  }
});
