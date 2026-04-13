export const vizDataString = JSON.stringify({
  "rootPackageName": "demo_workspace",
  "packages": {
    "_fe_analyzer_shared": {
      "name": "_fe_analyzer_shared",
      "version": "99.0.0",
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
      "version": "12.1.0",
      "dependencies": [
        {
          "name": "_fe_analyzer_shared",
          "versionConstraint": "^99.0.0"
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
    "args": {
      "name": "args",
      "version": "2.0.0",
      "dependencies": [],
      "onlyDev": false
    },
    "async": {
      "name": "async",
      "version": "2.13.1",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        },
        {
          "name": "meta",
          "versionConstraint": "^1.3.0"
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
          "versionConstraint": "^1.3.0",
          "includesLatest": true
        }
      ]
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
          "versionConstraint": "^1.3.0",
          "includesLatest": true
        }
      ]
    },
    "dart_flutter_team_lints": {
      "name": "dart_flutter_team_lints",
      "version": "3.0.0",
      "dependencies": []
    },
    "demo_workspace": {
      "name": "demo_workspace",
      "dependencies": [
        {
          "name": "dart_flutter_team_lints",
          "versionConstraint": "^3.0.0",
          "isDevDependency": true
        }
      ],
      "isPrimary": true,
      "onlyDev": false
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
          "versionConstraint": "^1.3.0",
          "includesLatest": true
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
      ]
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
      "dependencies": []
    },
    "mime": {
      "name": "mime",
      "version": "2.0.0",
      "dependencies": []
    },
    "node_preamble": {
      "name": "node_preamble",
      "version": "2.0.2",
      "dependencies": []
    },
    "outdated_pkg": {
      "name": "outdated_pkg",
      "version": "1.0.0",
      "dependencies": [],
      "onlyDev": false,
      "latestVersion": "2.0.0"
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
    "pkg_a": {
      "name": "pkg_a",
      "dependencies": [
        {
          "name": "args",
          "versionConstraint": "^2.0.0"
        },
        {
          "name": "http_parser",
          "versionConstraint": "^4.0.0"
        },
        {
          "name": "typed_data",
          "versionConstraint": "<1.4.0",
          "includesLatest": false
        },
        {
          "name": "test",
          "versionConstraint": "^1.25.0",
          "isDevDependency": true
        }
      ],
      "isPrimary": true,
      "onlyDev": false,
      "isPublishToNone": true
    },
    "pkg_b": {
      "name": "pkg_b",
      "version": "1.0.0",
      "dependencies": [
        {
          "name": "http_parser",
          "versionConstraint": "^4.0.0"
        },
        {
          "name": "outdated_pkg",
          "versionConstraint": "^1.0.0",
          "includesLatest": false
        },
        {
          "name": "pkg_a",
          "versionConstraint": "any"
        },
        {
          "name": "test",
          "versionConstraint": "^1.25.0",
          "isDevDependency": true
        }
      ],
      "isPrimary": true,
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
    "pub_semver": {
      "name": "pub_semver",
      "version": "2.2.0",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
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
      ]
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
      ]
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
      ]
    },
    "stream_channel": {
      "name": "stream_channel",
      "version": "2.1.4",
      "dependencies": [
        {
          "name": "async",
          "versionConstraint": "^2.5.0"
        }
      ]
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
          "versionConstraint": "^1.3.0",
          "includesLatest": true
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
    "typed_data": {
      "name": "typed_data",
      "version": "1.3.2",
      "dependencies": [
        {
          "name": "collection",
          "versionConstraint": "^1.15.0"
        }
      ],
      "onlyDev": false,
      "latestVersion": "1.4.0"
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
      "dependencies": []
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
      ]
    }
  },
  "isWorkspace": true
});
