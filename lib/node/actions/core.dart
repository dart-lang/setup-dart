// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:js/js.dart' as js;

@JS()
external Core get core;

@JS()
@js.staticInterop
class Core {}

extension CoreExtension on Core {
  external JSString getInput(JSString name);

  external void setOutput(JSString name, JSString value);

  external void info(JSString name);
  external void warning(JSString name);
  external void error(JSString name);

  external void addPath(JSString element);

  external void exportVariable(JSString name, JSString value);

  external void setFailed(JSString name);

  // JSPromise<String>
  external JSPromise getIDToken(JSString audience);
}
