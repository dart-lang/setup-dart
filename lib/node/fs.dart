// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

/// POSIX functions for interacting with the file system.
/// Wraps https://nodejs.org/api/fs.html
@JS()
external FileSystem get fs;

@JS()
inline class FileSystem {
  final JSObject fileSystem;
  FileSystem(this.fileSystem);

  /// Whether the [path] exists, false otherwise.
  @JS()
  external JSBoolean existsSync(JSString path);

  /// Read the contents of the [path].
  @JS()
  external JSString readFileSync(JSString path, [JSString encoding]);
}
