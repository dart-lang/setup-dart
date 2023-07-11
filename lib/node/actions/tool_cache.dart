// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
external ToolCache get toolCache;

@JS()
inline class ToolCache {
  final JSObject obj;

  ToolCache(this.obj);

  /// Finds the path to a tool version in the local installed tool cache.
  ///
  /// @param toolName      name of the tool
  /// @param versionSpec   version of the tool
  /// @param arch          optional arch.  defaults to arch of computer
  external String find(
    String toolName,
    String versionSpec, [
    String? arch,
  ]);

  /// Download a tool from an url and stream it into a file.
  ///
  /// @param url       url of tool to download
  /// @returns         path to downloaded tool
  // JSPromise<String>
  external JSPromise downloadTool(String url);

  /// Extract a zip.
  ///
  /// @param file     path to the zip
  /// @returns        path to the destination directory
  external JSPromise extractZip(String file);

  /// Caches a directory and installs it into the tool cacheDir
  ///
  /// @param sourceDir     the directory to cache into tools
  /// @param tool          tool name
  /// @param version       version of the tool.  semver format
  /// @param arch          architecture of the tool.  Optional.
  ///                      Defaults to machine architecture
  external JSPromise cacheDir(
    String sourceDir,
    String tool,
    String version, [
    String? arch,
  ]);
}
