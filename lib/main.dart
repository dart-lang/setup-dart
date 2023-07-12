// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_util';

import 'package:path/path.dart' as path;

import 'node/actions/core.dart';
import 'node/actions/exec.dart';
import 'node/actions/http_client.dart';
import 'node/actions/tool_cache.dart';
import 'node/fs.dart';
import 'node/os.dart';
import 'node/process.dart';

void main(List<String> args) async {
  try {
    // sdk
    var sdk = core.getInput('sdk');
    if (sdk.isEmpty) {
      sdk = 'stable';
    }

    // flavor
    var flavor = core.getInput('flavor');
    if (flavor.isEmpty) {
      flavor = sdk == 'main' ? 'raw' : 'release';
    } else if (flavor != 'raw' && flavor != 'release') {
      core.setFailed("Unrecognized build flavor '$flavor'.");
      return;
    }
    final raw = flavor == 'raw';

    // os
    final os = getPlatform();

    // architecture
    var architecture = core.getInput('architecture');
    if (architecture.isEmpty) {
      architecture = getArch();
    }

    // calculate version and channel
    String version;
    String channel;

    if (sdk == 'stable' || sdk == 'beta' || sdk == 'dev') {
      channel = sdk;
      version =
          raw ? 'latest' : (await latestPublishedVersion(channel, flavor));
    } else if (sdk == 'main') {
      channel = 'be';
      version =
          raw ? 'latest' : (await latestPublishedVersion(channel, flavor));
    } else {
      version = sdk;

      // Derive the channel from the version string.
      if (sdk.contains('dev')) {
        channel = 'dev';
      } else if (sdk.contains('beta')) {
        channel = 'beta';
      } else if (sdk.contains('main')) {
        core.setFailed('Versions cannot be specified for main channel builds.');
        return;
      } else {
        channel = 'stable';
      }
    }

    core.info('Installing the $os-$architecture Dart SDK version $version from '
        'the $channel ($flavor) channel.');

    // Calculate url based on https://dart.dev/tools/sdk/archive#download-urls.
    final url = 'https://storage.googleapis.com/dart-archive/'
        'channels/$channel/$flavor/$version/sdk/'
        'dartsdk-$os-$architecture-release.zip';

    // Use a cached sdk or download and cache the sdk; using a 'raw' sdk flavor
    // disables caching.
    final toolName = raw ? 'dart_raw' : 'dart';
    var sdkPath = !raw ? toolCache.find(toolName, version, architecture) : '';
    if (sdkPath.isNotEmpty) {
      core.info('Using cached sdk from $sdkPath.');
    } else {
      core.info('$url ...');

      final archivePath =
          await promiseToFuture<String>(toolCache.downloadTool(url));
      var extractedFolder =
          await promiseToFuture<String>(toolCache.extractZip(archivePath));
      extractedFolder = path.join(extractedFolder, 'dart-sdk');

      sdkPath = await promiseToFuture<String>(
          toolCache.cacheDir(extractedFolder, toolName, version, architecture));
    }

    final pubCache = path.join(
        process.env(os == 'windows' ? 'USERPROFILE' : 'HOME')!, '.pub-cache');

    core.exportVariable('DART_HOME', sdkPath);
    core.addPath(path.join(sdkPath, 'bin'));
    core.exportVariable('PUB_CACHE', pubCache);
    core.addPath(path.join(pubCache, 'bin'));

    // Create the OIDC token used for pub.dev publishing.
    await createPubOIDCToken();

    // Configure the outputs.
    if (raw) {
      core.setOutput('dart-version', getVersionFromSdk(sdkPath));
    } else {
      core.setOutput('dart-version', version);
    }

    // Report success; print version.
    await promiseToFuture(exec.exec(
      'dart',
      ['--version'.toJS].toJS,
    ));
  } catch (error) {
    core.setFailed('$error');
  }
}

String getVersionFromSdk(String sdkPath) {
  final versionFilePath = path.join(sdkPath, 'version');
  return fs.readFileSync(versionFilePath, 'utf8').trim();
}

/// Returns 'x64', 'ia32', 'arm', or 'arm64'.
String getArch() {
  const supported = ['x64', 'ia32', 'arm', 'arm64'];
  return supported.contains(os.arch) ? os.arch : 'x64';
}

/// Returns 'linux', 'windows', or 'macos'.
String getPlatform() {
  return switch (os.platform) {
    'win32' => 'windows',
    'darwin' => 'macos',
    _ => 'linux'
  };
}

// When enabled through env variables, create an OIDC token for publishing on
// pub.dev.
Future<void> createPubOIDCToken() async {
  final tokenRequestUrl = process.env('ACTIONS_ID_TOKEN_REQUEST_URL');
  final tokenRequestToken = process.env('ACTIONS_ID_TOKEN_REQUEST_TOKEN');

  if (tokenRequestUrl == null || tokenRequestToken == null) {
    return;
  }

  final token =
      await promiseToFuture<String>(core.getIDToken('https://pub.dev'));

  core.exportVariable('PUB_TOKEN', token);

  await promiseToFuture(exec.exec(
    'dart',
    [
      'pub'.toJS,
      'token'.toJS,
      'add'.toJS,
      'https://pub.dev'.toJS,
      '--env-var'.toJS,
      'PUB_TOKEN'.toJS,
    ].toJS,
  ));
}

// https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION
// {
//   "date": "2023-02-07",
//   "version": "2.19.2",
//   "revision": "e46b4f59490230778e907bde2eedb06b062d31be"
// }

// Query google storage for the most recent published SDK version for the given
// channel and flavor.
Future<String> latestPublishedVersion(String channel, String flavor) async {
  final url = 'https://storage.googleapis.com/dart-archive/channels/'
      '$channel/$flavor/latest/VERSION';

  final http = HttpClient(
    'setup-dart',
    <JSAny>[].toJS,
    jsify({
      'allowRedirects': true,
      'maxRedirects': 3,
      'allowRetries': true,
      'maxRetries': 3,
    }) as JSObject?,
  );

  var response = await promiseToFuture<JSObject>(http.getJson(url));
  var result = getProperty<JSObject>(response, 'result');
  return getProperty(result, 'version');
}
