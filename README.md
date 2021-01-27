# setup-dart

[![Dart](https://github.com/dart-lang/setup-dart/workflows/Dart/badge.svg)](https://github.com/dart-lang/setup-dart/actions?query=workflow%3A%22Dart%22+branch%3Amain)

This [GitHub Action]() installs and sets up of a Dart SDK for use in actions by:

* Downloading the Dart SDK
* Adding the `dart` command and `pub` cache to path

# Usage

## Inputs

The action takes the following inputs:

  * `sdk`: Which SDK version to setup. Can be specified using one of two forms:
    * A specific SDK version, e.g. `2.7.2` or `2.12.0-1.4.beta`
    * A release channel, which will install the latest build from that channel.
      Available channels are `stable`, `beta`, `dev`, and `main`. See
      https://dart.dev/tools/sdk/archive for details.

  * `architecture`: The CPU architecture to setup support for. Valid options are
    `x64`, `ia32`, `arm`, and `arm64`. Note that not all CPU architectures are
    supported on all operating systems; see https://dart.dev/tools/sdk/archive
    for valid combinations.

## Basic example

Install the latest stable SDK, and run Hello World.

```yml
name: Dart

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1

      - name: Install dependencies
        run: dart pub get

      - name: Hello world
        run: dart bin/hello_world.dart
```

## Check static analysis, formatting, and test example

Various static checks:

  1) Check static analysis with the Dart analyzer
  2) Check code follows Dart idiomatic formatting
  3) Check that unit tests pass

```yml
...
    steps:

      - name: Install dependencies
        run: dart pub get

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Analyze project source
        run: dart analyze

      - name: Run tests
        run: dart test
```

## Matrix testing example

You can create matrix jobs that run tests on multiple operating systems, and
multiple versions of the Dart SDK.

The following example create a double matrix across two dimensions:

  - All three major operating systems: Linux, macOS, and Windows.
  - Five Dart SDKs: Latest stable, beta & dev plus two specific versions.

```yml
name: Dart

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        sdk: [stable, beta, dev, 2.10.3, 2.12.0-29.10.beta]
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: ${{ matrix.sdk }}

      - name: Install dependencies
        run: dart pub get

      - name: Run tests
        run: dart test
```

## Testing older Dart SDKs example

The Dart SDK continously evolves, and new features and tools are added. The Dart
2.10 SDK introduced a new unified `dart` developer tool, which is what we use in
the usage examples above for installing dependencies, verifying formatting,
analyzing, etc. If you need to test a combination of SDKs before and after Dart
2.10, we recommend splitting your test job as illustrated here:

```yml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        sdk: [stable, beta, dev]
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@main
        with:
          sdk: ${{ matrix.sdk }}
      - name: Install dependencies
        run: dart pub get
      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed .
      - name: Analyze code
        run: dart analyze
      - name: Run tests
        run: dart test

  test_old_sdks:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        sdk: [2.9.0, 2.8.1]
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@main
        with:
          sdk: ${{ matrix.sdk }}
      - name: Install dependencies
        run: pub get
      - name: Check formatting
        run: dartfmt --dry-run --set-exit-if-changed .
      - name: Analyze code
        run: dartanalyzer --fatal-warnings .
      - name: Run tests
        run: pub run test
```

# Version history

## v0.4

  * Added support for specifying the CPU architecture.

## v0.3

  * Added support for installing SDKs from the `main` channel.

## v0.2

  * Added support for installing a specific SDK version (e.g. `2.10.0`).

## v0.1

  * Initial version.

# License

See the [`LICENSE`](LICENSE) file.
