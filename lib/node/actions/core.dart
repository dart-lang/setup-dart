// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
external Core get core;

@JS()
inline class Core {
  @JS()
  external JSString getInput(JSString name);

  @JS()
  external void setOutput(JSString name, JSString value);

  @JS()
  external void info(JSString name);
  @JS()
  external void warning(JSString name);
  @JS()
  external void error(JSString name);

  @JS()
  external void addPath(JSString element);

  @JS()
  external void exportVariable(JSString name, JSString value);

  @JS()
  external void setFailed(JSString name);

  @JS()
  // JSPromise<String>
  external JSPromise getIDToken(JSString audience);
}
