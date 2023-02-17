// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import path from 'path'
import * as core from '@actions/core'
import * as exec from '@actions/exec'
import * as sdk_utils from './sdk'
import * as system from './system'
import * as odic from './odic'
import * as versions from './versions'
import * as tc from '@actions/tool-cache'

// TODO: Support version patterns of '2.19.x' to mean the latest 2.19 version.

// TODO: Cache pub packages; have an input flag to control this.

// TODO: have an input parameter to control creation of the ODIC token?

export async function install(): Promise<void> {
  try {
    // sdk
    let sdk: string = core.getInput('sdk')
    if (sdk.length === 0) {
      sdk = 'stable'
    }

    // flavor
    let flavor: string = core.getInput('flavor')
    if (flavor.length === 0) {
      flavor = sdk === 'main' ? 'raw' : 'release'
    } else if (flavor !== 'raw' && flavor !== 'release') {
      core.setFailed(`Unrecognized build flavor '${flavor}'.`)
      return
    }
    const raw = flavor === 'raw'

    // os
    const os: string = system.getPlatform()

    // architecture
    let architecture: string = core.getInput('architecture')
    if (architecture.length === 0) {
      architecture = system.getArch()
    }

    // calculate version and channel
    let version: string
    let channel: string

    if (sdk === 'stable' || sdk === 'beta' || sdk === 'dev') {
      channel = sdk
      version = raw
        ? 'latest'
        : ((await versions.latestPublishedVersion(channel, flavor)) as string)
    } else if (sdk === 'main') {
      channel = 'be'
      version = raw
        ? 'latest'
        : ((await versions.latestPublishedVersion(channel, flavor)) as string)
    } else {
      version = sdk

      // Derive the channel from the version string.
      if (sdk.includes('dev')) {
        channel = 'dev'
      } else if (sdk.includes('beta')) {
        channel = 'beta'
      } else if (sdk.includes('main')) {
        core.setFailed('Versions cannot be specified for main channel builds.')
        return
      } else {
        channel = 'stable'
      }
    }

    core.info(
      `Installing the ${os}-${architecture} Dart SDK version ${version} from ` +
        `the ${channel} (${flavor}) channel.`
    )

    // Calculate url based on https://dart.dev/tools/sdk/archive#download-urls.
    const url =
      'https://storage.googleapis.com/dart-archive/' +
      `channels/${channel}/${flavor}/${version}/sdk/` +
      `dartsdk-${os}-${architecture}-release.zip`

    // Use a cached sdk or download and cache the sdk; using a 'raw' sdk flavor
    // disables caching.
    const toolName = flavor === 'raw' ? 'dart_raw' : 'dart'
    let sdkPath = !raw ? tc.find(toolName, version, architecture) : null
    if (sdkPath) {
      core.info(`Using cached sdk from ${sdkPath}.`)
    } else {
      core.info(url)

      const archivePath = await tc.downloadTool(url)
      let extractedFolder = await tc.extractZip(archivePath)
      extractedFolder = path.join(extractedFolder, 'dart-sdk')

      sdkPath = await tc.cacheDir(
        extractedFolder,
        toolName,
        version,
        architecture
      )
    }

    const pubCache = path.join(
      process.env[os === 'windows' ? 'USERPROFILE' : 'HOME'] as string,
      '.pub-cache'
    )

    core.exportVariable('DART_HOME', sdkPath)
    core.addPath(path.join(sdkPath, 'bin'))
    core.exportVariable('PUB_CACHE', pubCache)
    core.addPath(path.join(pubCache, 'bin'))

    // Potentially create the ODIC token used for pub.dev publishing.
    odic.createPubOIDCToken()

    // Configure the outputs.
    if (raw) {
      core.setOutput('dart-version', sdk_utils.getVersionFromSdk(sdkPath))
    } else {
      core.setOutput('dart-version', version)
    }

    // Report success; print version.
    await exec.exec('dart', ['--version'])
  } catch (error) {
    if (error instanceof Error) core.setFailed(error.message)
  }
}
