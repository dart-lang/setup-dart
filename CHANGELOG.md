## v1.7.0

- Install flutter sdk in publishing step, allowing Flutter packages to be
  published ([#68][]) 
  
  [#68]: https://github.com/dart-lang/setup-dart/issues/68

## v1.6.5

- Fix zip path handling on Windows 11 ([#118][])

[#118]: https://github.com/dart-lang/setup-dart/issues/118

## v1.6.4

* Rebuild JS code.

## v1.6.3

* Roll `undici` dependency to address [CVE-2024-30260][] and [CVE-2024-30261][].

[CVE-2024-30260]: https://github.com/nodejs/undici/security/advisories/GHSA-m4v8-wqvr-p9f7
[CVE-2024-30261]: https://github.com/nodejs/undici/security/advisories/GHSA-9qxr-qj54-h672

## v1.6.2

* Switch to running the workflow on `node20`` from `node16`. See also
  [Transitioning from Node 16 to Node 20][].

[Transitioning from Node 16 to Node 20]: https://github.blog/changelog/2023-09-22-github-actions-transitioning-from-node-16-to-node-20/

## v1.6.1

* Updated the google storage url for `main` channel releases.

## v1.6.0

* Enable provisioning of the latest Dart SDK patch release by specifying just
  the major and minor version (e.g. `3.2`).

## v1.5.1

* No longer test the `setup-dart` action on pre-2.12 SDKs.
* Upgrade JS interop code to use extension types
  (the new name for inline classes).
* The upcoming rename of the `be` channel to `main` is now supported with
  forward compatibility that switches when the rename happens.

## v1.5.0

* Re-wrote the implementation of the action into Dart.
* Auto-detect the platform architecture (`x64`, `ia32`, `arm`, `arm64`).
* Improved the caching and download resilience of the sdk.
* Added a new action output: `dart-version` - the installed version of the sdk.

## v1.4.0

* Automatically create OIDC token for pub.dev.
* Add a reusable workflow for publishing.

## v1.3.0

* The install location of the Dart SDK is now available
  in an environment variable, `DART_HOME`
  ([#43](https://github.com/dart-lang/setup-dart/issues/43)).
* Fixed an issue where cached downloads could lead to unzip issues
  on self-hosted runners
  ([#35](https://github.com/dart-lang/setup-dart/issues/35)).

## v1.2.0

* Fixed a path issue impacting git dependencies on Windows.

## v1.1.0

* Added a `flavor` option setup.sh to allow downloading unpublished builds.

## v1.0.0

* Promoted to 1.0 stable.

## v0.5

* Fixed a Windows `pub global activate` path issue.

## v0.4

* Removed previously deprecated input `channel`. Use the `sdk` input instead.
* Added support for specifying the CPU architecture.

## v0.3

* Added support for installing SDKs from the `main` channel.

## v0.2

* Added support for installing a specific SDK version (e.g. `2.10.0`).

## v0.1

* Initial version.
