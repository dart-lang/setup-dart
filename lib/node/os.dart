// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

/// Operating system-related utility methods and properties.
/// Wraps https://nodejs.org/api/os.html
@JS()
external OS get os;

@JS()
inline class OS {
  final JSObject os;
  OS(this.os);

  @JS('arch')
  external JSString _arch();

  /// The operating system CPU architecture.
  JSString get arch => _arch();

  @JS('platform')
  external JSString _platform();

  /// The operating system platform.
  JSString get platform => _platform();
}
