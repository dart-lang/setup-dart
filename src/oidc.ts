// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import * as core from '@actions/core'
import * as exec from '@actions/exec'

// When enabled through env variables, create OIDC token for publishing on
// pub.dev.
export async function createPubOIDCToken(): Promise<void> {
  const tokenRequestUrl = process.env['ACTIONS_ID_TOKEN_REQUEST_URL']
  const tokenRequestToken = process.env['ACTIONS_ID_TOKEN_REQUEST_TOKEN']

  if (tokenRequestUrl == null || tokenRequestToken == null) {
    return
  }

  const token = await core.getIDToken('https://pub.dev')

  core.exportVariable('PUB_TOKEN', token)

  await exec.exec('dart', [
    'pub',
    'token',
    'add',
    'https://pub.dev',
    '--env-var',
    'PUB_TOKEN'
  ])
}
