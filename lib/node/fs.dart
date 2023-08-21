// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

/// POSIX functions for interacting with the file system.
/// Wraps https://nodejs.org/api/fs.html
@JS()
external FileSystem get fs;

@JS()
extension type FileSystem (JSObject fileSystem) {
  /// Whether the [path] exists, false otherwise.
  external bool existsSync(String path);

  /// Read the contents of the [path].
  external String readFileSync(String path, [String encoding]);
}
