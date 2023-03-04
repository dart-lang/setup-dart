// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:js/js.dart' as js;

@JS()
@js.staticInterop
class HttpClient {
  external factory HttpClient(
      JSString userAgent, JSArray handlers, Map requestOptions);
}

extension HttpClientExtension on HttpClient {
  // JSPromise<JSObject>
  external JSPromise getJson(JSString requestUrl);
}
