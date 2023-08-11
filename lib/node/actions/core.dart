// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
external Core get core;

@JS()
extension type Core (JSObject obj) {
  external String getInput(String name);

  external void setOutput(String name, String value);

  external void info(String name);
  external void warning(String name);
  external void error(String name);

  external void addPath(String element);

  external void exportVariable(String name, String value);

  external void setFailed(String name);

  // JSPromise<String>
  external JSPromise getIDToken(String audience);
}
