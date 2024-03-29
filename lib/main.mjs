// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import * as core from '@actions/core';
import * as exec from '@actions/exec';
import * as httpClient from '@actions/http-client';
import * as toolCache from '@actions/tool-cache';
import * as fs from 'fs';
import * as module from 'module';
import * as os from 'os';
import process from 'process';

const require = module.createRequire(import.meta.url);

// Setup properties for JS interop in Dart.

globalThis.self = globalThis;
globalThis.core = core;
globalThis.exec = exec;
globalThis.HttpClient = httpClient.HttpClient;
globalThis.toolCache = toolCache;
globalThis.fs = fs;
globalThis.os = os;
globalThis.process = process;
globalThis.location = { href: `file://${process.cwd()}/`}

globalThis.dartMainRunner = async function(main, args) {
  const dir = process.argv[2];
  await main(dir);
}

async function scriptMain() {
  // We have to load `main.js` here so that the `dartMainRunner` hook is
  // registered before the IIFE in `dart_main.js` runs.
  require('../dist/main.cjs');
}

if (require.main === require.module) {
  await scriptMain();
}
