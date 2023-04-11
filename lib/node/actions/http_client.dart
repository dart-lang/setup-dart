// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
inline class HttpClient {
  external HttpClient(
    JSString userAgent,
    JSArray handlers,
    Map requestOptions,
  );

  // JSPromise<JSObject>
  external JSPromise getJson(JSString requestUrl);
}
