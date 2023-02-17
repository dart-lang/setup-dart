// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import {arch, platform} from 'os'

// Returns 'linux', 'windows', or 'macos'.
export function getPlatform(): string {
  if (platform() === 'win32') return 'windows'
  return platform() === 'darwin' ? 'macos' : 'linux'
}

// Returns 'x64', 'ia32', 'arm', or 'arm64'.
export function getArch(): string {
  const supported = ['x64', 'ia32', 'arm', 'arm64']
  return supported.includes(arch()) ? arch() : 'x64'
}
