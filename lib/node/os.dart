// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

/// Operating system-related utility methods and properties.
/// Wraps https://nodejs.org/api/os.html
@JS()
external OS get os;

@JS()
extension type OS (JSObject obj) {
  @JS('arch')
  external String _arch();

  /// The operating system CPU architecture.
  String get arch => _arch();

  @JS('platform')
  external String _platform();

  /// The operating system platform.
  String get platform => _platform();
}
