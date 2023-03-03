[![Build](https://github.com/dart-lang/setup-dart/actions/workflows/build.yml/badge.svg)](https://github.com/dart-lang/setup-dart/actions/workflows/build.yml)
[![Dart](https://github.com/dart-lang/setup-dart/actions/workflows/dart.yml/badge.svg)](https://github.com/dart-lang/setup-dart/actions/workflows/dart.yml)

## Setting up

1. Install node
1. Install additional node tooling (`npm i -g @vercel/ncc`)
1. Install the node package dependencies (`npm install`)

## Development

tldr: edit Dart source files; run `npm run all` to re-compile the action

### Working on the action

Generally, to work on the action, edit the Dart source code in `lib/` and
re-compile the JavaScript code via `npm run all`. This will:

- compile the Dart source (via dart2js) to `lib/main.js`; copy that file to
  `dist/main.cjs`
- package and minify the `lib/main.mjs` entrypoint point and referencd node
  modules to `dist/index.mjs`

### Files

`lib/main.dart` - the Dart entry-point to the action.

`lib/main.mjs` - the JavaScript wrapper; this sets up some important JS interop
globals and bootstraps into `lib/main.dart`. 

`dist/index.mjs` - the execution entry-point of the action.

## Releasing

See our
[publishing](https://github.com/dart-lang/setup-dart/wiki/Publishing-procedure)
wiki page.
