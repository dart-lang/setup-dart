# setup-dart

[setup-dart][] installs and sets up a Dart SDK for use in GitHub Actions; it:

* downloads the Dart SDK
* adds the [`dart`](https://dart.dev/tools/dart-tool) tool to the system path

[setup-dart]: https://github.com/marketplace/actions/setup-dart-sdk

## Usage

To install the latest stable Dart SDK and run typical checks:

```yml
name: Dart

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1

      - run: dart pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: dart analyze
      - run: dart test
```

## Inputs

The action takes the following inputs:

  * `sdk`: Which SDK version to setup. Can be specified using one of three forms:
    * A release channel, which will install the latest build from that channel.
      Available channels are `stable`, `beta`, `dev`, and `main`. See the
      [Dart SDK archive](https://dart.dev/get-dart/archive) for details.
    * An SDK release version - e.g. `2.19` or `3.1`. This will install the
      latest patch release for that specific release version.
    * A specific SDK version, e.g. `2.19.0` or `2.12.0-1.4.beta`.

  * `flavor`: Which build flavor to setup.
    * The available build flavors are `release` and `raw`.
    * The `release` flavor contains published builds.
    * The `raw` flavor contains unpublished builds; these can be used by
      developers to test against SDK versions before a signed release is
      available. Note that the  `main` release channel only supports the `raw`
      build flavor.

  * `architecture`: The CPU architecture to setup support for.
    * Valid options are `x64`, `ia32`, `arm`, and `arm64`.
    * Note that not all CPU architectures are supported on all operating
      systems; see the 
      [Dart system requirements](https://dart.dev/get-dart#system-requirements)
      for valid combinations.

## Outputs

The action produces the following output:

  * `dart-version`: The version of the Dart SDK that was installed.

## Matrix testing example

You can create matrix jobs that run tests on multiple operating systems, and
multiple versions of the Dart SDK.

The following example creates a matrix across two dimensions:

- three major operating systems: Linux, MacOS, and Windows
- several Dart SDK versions: a specific version, the latest stable, beta, and
  dev

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
        sdk: [3.1, stable, beta]
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: ${{ matrix.sdk }}

      - name: Install dependencies
        run: dart pub get

      - name: Run tests
        run: dart test
```

## License

See the [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## Version history

Please see our [CHANGELOG.md](CHANGELOG.md) file.
