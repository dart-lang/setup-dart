// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import * as hc from '@actions/http-client'

// https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION
// {
//   "date": "2023-02-07",
//   "version": "2.19.2",
//   "revision": "e46b4f59490230778e907bde2eedb06b062d31be"
// }

// Query google storage for the most recent published SDK version for the given
// channel and flavor.
export async function latestPublishedVersion(
  channel: string,
  flavor: string
): Promise<string | null> {
  const url =
    'https://storage.googleapis.com/dart-archive/channels/' +
    `${channel}/${flavor}/latest/VERSION`

  const http = new hc.HttpClient('setup-dart', [], {
    allowRedirects: true,
    maxRedirects: 3,
    allowRetries: true,
    maxRetries: 3
  })

  const result = (await http.getJson<IVersionData>(url)).result
  return result == null ? null : result.version
}

interface IVersionData {
  date: string
  version: string
  revision: string
}
