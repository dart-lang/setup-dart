// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:js/js.dart' as js;

/// POSIX functions for interacting with the file system.
/// Wraps https://nodejs.org/api/fs.html
@JS()
external FileSystem get fs;

@JS()
@js.staticInterop
inline class FileSystem {
  final JSObject fileSystem;
  FileSystem(this.fileSystem);

  @JS()
  /// Returns true if the [path] exists, false otherwise.
  external JSBoolean existsSync(JSString path);

  @JS()
  /// Returns the contents of the [path].
  external JSString readFileSync(JSString path, [JSString encoding]);
}
