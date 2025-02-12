// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

@JS()
extension type HttpClient._(JSObject obj) {
  external HttpClient(
    String userAgent, [
    JSArray? handlers,
    JSObject? requestOptions,
  ]);

  // JSPromise<HttpClientResponse>
  external JSPromise<JSObject> get(String requestUrl);
  external JSPromise<JSObject?> getJson(String requestUrl);
}

@JS()
extension type HttpClientResponse._(JSObject obj) {
  external JSPromise<JSString> readBody();
}
