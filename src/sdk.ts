// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import fs from 'fs'
import path from 'path'

export function getVersionFromSdk(sdkPath: string): string | null {
  const versionFilePath = path.join(sdkPath, 'version')

  if (fs.existsSync(versionFilePath)) {
    return fs.readFileSync(versionFilePath, 'utf8').trim()
  } else {
    return null
  }
}
