// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
external Exec get exec;

@JS()
inline class Exec {
  /// Exec a command.
  ///
  /// Output will be streamed to the live console. Returns promise with return
  /// code.
  external JSPromise exec(String commandLine, [List<String> args]);
}
