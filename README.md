# setup-dart

[![Dart](https://github.com/dart-lang/setup-dart/workflows/Dart/badge.svg)](https://github.com/dart-lang/setup-dart/actions?query=workflow%3A%22Dart%22+branch%3Amain)

This [GitHub Action]() installs and sets up of a Dart SDK for use in actions by:

* Downloading the Dart SDK
* Adding the `dart` command and `pub` cache to path

# Usage

## Basic

Install the latest stable SDK, and run Hello World.

```
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

## Check static analysis, formatting, and tests

Various static checks:

  1) Check static analysis with the Dart analyzer
  2) Check code follows Dart ideomatic formatting
  3) Check that unit tests pass

```
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

## Matrix testing

Double matrix across two dimensions:

  - All three major operating systems: Linux, macOS, and Windows.
  - Dart release channels: stable, beta, dev.

```
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
        channel: [stable, beta, dev]
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
        with:
          channel: ${{ matrix.channel }}

      - name: Install dependencies
        run: dart pub get

      - name: Run tests
        run: dart test
```

## Specifying a stable version

By default, the `latest` release is used that has been published within the specified `channel`.

If you want to test on a previous release from the `stable` channel, you can specify it following an `@` 
delimiter as shown below:

```
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
        channel: [stable, stable@2.7.2]
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
        with:
          channel: ${{ matrix.channel }}

      - name: Install dependencies
        run: dart pub get

      - name: Run tests
        run: dart test
```

# License

See the [`LICENSE`](LICENSE) file.
