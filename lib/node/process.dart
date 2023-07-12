// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_util';

/// Provides information about, and control over, the current Node.js process.
/// Wraps https://nodejs.org/api/process.html
@JS()
external Process get process;

@JS()
inline class Process {
  final JSObject process;

  Process(this.process);

  @JS('env')
  // Map<String, String?>
  external JSObject _env;

  /// Read the environment variable [variable].
  String? env(String variable) => getProperty<String?>(_env, variable);
}
