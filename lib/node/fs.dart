// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:js/js.dart' as js;

@JS()
external FileSystem get fs;

@JS()
@js.staticInterop
class FileSystem {}

extension FileSystemExtension on FileSystem {
  external JSBoolean existsSync(JSString path);

  external JSString readFileSync(JSString path, [JSString encoding]);
}
