// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:js/js.dart' as js;

@JS()
external ToolCache get toolCache;

@JS()
@js.staticInterop
class ToolCache {}

extension ToolCacheExtension on ToolCache {
  ///Finds the path to a tool version in the local installed tool cache.
  ///
  /// @param toolName      name of the tool
  /// @param versionSpec   version of the tool
  /// @param arch          optional arch.  defaults to arch of computer
  external JSString find(
    JSString toolName,
    JSString versionSpec, [
    JSString arch,
  ]);

  // JSPromise<String>
  /// Download a tool from an url and stream it into a file.
  ///
  /// @param url       url of tool to download
  /// @returns         path to downloaded tool
  external JSPromise downloadTool(JSString url);

  /// Extract a zip.
  ///
  /// @param file     path to the zip
  /// @returns        path to the destination directory
  external JSPromise extractZip(JSString file);

  /// Caches a directory and installs it into the tool cacheDir
  ///
  /// @param sourceDir    the directory to cache into tools
  /// @param tool          tool name
  /// @param version       version of the tool.  semver format
  /// @param arch          architecture of the tool.  Optional.
  ///                      Defaults to machine architecture
  external JSPromise cacheDir(
    JSString sourceDir,
    JSString tool,
    JSString version, [
    JSString arch,
  ]);
}