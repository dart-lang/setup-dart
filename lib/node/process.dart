// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_util';

import 'package:js/js.dart' as js;

@JS()
external Process get process;

@JS()
@js.staticInterop
class Process {}

extension ProcessExtension on Process {
  // Map<String, String?>
  external JSObject env;
}

String? getProcessEnv(String name) => getProperty<String?>(process.env, name);
