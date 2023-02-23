// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:js/js.dart' as js;

@JS()
external OS get os;

@JS()
@js.staticInterop
class OS {}

extension OSExtension on OS {
  external JSString arch();

  external JSString platform();
}
