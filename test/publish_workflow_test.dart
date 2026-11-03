// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('posix')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

void main() {
  late String workflowText;
  late String resolveStepScript;

  setUpAll(() {
    final workflowFile = File('.github/workflows/publish.yml');
    expect(workflowFile.existsSync(), isTrue);
    workflowText = workflowFile.readAsStringSync();
    resolveStepScript = _extractResolveDirScript(workflowText);
  });

  test('publish.yml wires resolve-dir output to validate and package jobs', () {
    expect(
      workflowText,
      contains(
        '    outputs:\n'
        '      working-directory: \${{ steps.resolve-dir.outputs.directory }}',
      ),
    );
    expect(
      workflowText,
      contains(
          'working-directory: \${{ steps.resolve-dir.outputs.directory }}'),
    );
    expect(
      workflowText,
      contains('PKG_DIR: \${{ needs.validate.outputs.working-directory }}'),
    );
  });

  Future<({int exitCode, String? directory, String stdout, String stderr})>
      runResolveDir({
    required String repoPath,
    String inputDir = '.',
    String refName = 'v1.0.0',
    bool testRun = false,
  }) async {
    final outputFile = File(p.join(d.sandbox, 'github_output.txt'));
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    outputFile.createSync();

    final proc = await TestProcess.start(
      'bash',
      ['--noprofile', '--norc', '-eo', 'pipefail', '-c', resolveStepScript],
      workingDirectory: repoPath,
      environment: {
        'INPUT_DIR': inputDir,
        'REF_NAME': refName,
        'TEST_RUN': testRun.toString(),
        'GITHUB_OUTPUT': outputFile.path,
      },
    );

    final exitCode = await proc.exitCode;
    final stdout = (await proc.stdout.rest.toList()).join('\n');
    final stderr = (await proc.stderr.rest.toList()).join('\n');

    String? directory;
    for (final line in outputFile.readAsLinesSync()) {
      if (line.startsWith('directory=')) {
        directory = line.substring('directory='.length);
      }
    }

    return (
      exitCode: exitCode,
      directory: directory,
      stdout: stdout,
      stderr: stderr,
    );
  }

  group('single-package root repository', () {
    test('resolves "." for v<version> and custom tags', () async {
      await d.dir('repo', [
        d.file('pubspec.yaml', 'name: my_pkg\nversion: 1.2.3\n'),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final res1 = await runResolveDir(repoPath: repoPath, refName: 'v1.2.3');
      expect(res1.exitCode, 0, reason: res1.stderr);
      expect(res1.directory, '.');

      final res2 = await runResolveDir(
        repoPath: repoPath,
        refName: 'release-v1.2.3',
      );
      expect(res2.exitCode, 0, reason: res2.stderr);
      expect(res2.directory, '.');
    });
  });

  group('monorepo automatic package discovery', () {
    test('discovers packages across multiple subdirectories', () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('pkg_a', [
            d.file('pubspec.yaml', 'name: pkg_a\nversion: 1.0.0\n'),
          ]),
        ]),
        d.dir('other_dir', [
          d.dir('pkg_b', [
            d.file('pubspec.yaml', 'name: pkg_b\nversion: 2.0.0\n'),
          ]),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final resA = await runResolveDir(
        repoPath: repoPath,
        refName: 'pkg_a-v1.0.0',
      );
      expect(resA.exitCode, 0, reason: resA.stderr);
      expect(resA.directory, 'pkgs/pkg_a');

      final resB = await runResolveDir(
        repoPath: repoPath,
        refName: 'pkg_b-v2.0.0-dev.1',
      );
      expect(resB.exitCode, 0, reason: resB.stderr);
      expect(resB.directory, 'other_dir/pkg_b');
    });

    test(
      'handles workspace root publish_to: none and ignores nested fixtures',
      () async {
        await d.dir('repo', [
          d.file(
            'pubspec.yaml',
            'name: pkg_a\npublish_to: none\nworkspace:\n  - pkgs/pkg_a\n',
          ),
          d.dir('pkgs', [
            d.dir('pkg_a', [
              d.file(
                'pubspec.yaml',
                'name: pkg_a\nversion: 1.0.0\nresolution: workspace\n',
              ),
              d.dir('test', [
                d.dir('fixtures', [
                  d.dir('nested_pkg', [
                    d.file(
                      'pubspec.yaml',
                      'name: nested_pkg\nversion: 0.0.1\n',
                    ),
                  ]),
                  d.dir('dup_a', [
                    d.file('pubspec.yaml', 'name: pkg_a\nversion: 0.0.1\n'),
                  ]),
                ]),
              ]),
            ]),
          ]),
        ]).create();

        final repoPath = p.join(d.sandbox, 'repo');

        // Resolves pkgs/pkg_a despite root workspace having publish_to: none
        // and nested test fixture having name: pkg_a.
        final resA = await runResolveDir(
          repoPath: repoPath,
          refName: 'pkg_a-v1.0.0',
        );
        expect(resA.exitCode, 0, reason: resA.stderr);
        expect(resA.directory, 'pkgs/pkg_a');

        // Nested fixture inside publishable package is not discoverable.
        final resNested = await runResolveDir(
          repoPath: repoPath,
          refName: 'nested_pkg-v0.0.1',
        );
        expect(resNested.exitCode, isNonZero);
        expect(resNested.stderr, contains("No package named 'nested_pkg'"));
      },
    );

    test('matches by pubspec name even when directory name differs', () async {
      await d.dir('repo', [
        d.dir('custom', [
          d.dir('folder_name', [
            d.file('pubspec.yaml', 'name: actual_pkg\nversion: 1.0.0\n'),
          ]),
        ]),
        d.dir('pkgs', [
          d.dir('on', [
            d.file('pubspec.yaml', 'name: on\nversion: 1.0.0\n'),
          ]),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final res = await runResolveDir(
        repoPath: repoPath,
        refName: 'actual_pkg-v1.0.0',
      );
      expect(res.exitCode, 0, reason: res.stderr);
      expect(res.directory, 'custom/folder_name');

      // Ensures YAML 1.1 boolean words like 'on' are preserved as strings.
      final resOn = await runResolveDir(
        repoPath: repoPath,
        refName: 'on-v1.0.0',
      );
      expect(resOn.exitCode, 0, reason: resOn.stderr);
      expect(resOn.directory, 'pkgs/on');
    });

    test('fails when tagged package has publish_to: none', () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('internal_pkg', [
            d.file(
              'pubspec.yaml',
              'name: internal_pkg\nversion: 1.0.0\npublish_to: none\n',
            ),
          ]),
        ]),
      ]).create();

      final res = await runResolveDir(
        repoPath: p.join(d.sandbox, 'repo'),
        refName: 'internal_pkg-v1.0.0',
      );
      expect(res.exitCode, isNonZero);
      expect(res.stderr, contains('publish_to: none'));
    });

    test('fails when multiple publishable packages share the same name',
        () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('dup', [
            d.file('pubspec.yaml', 'name: dup\nversion: 1.0.0\n'),
          ]),
        ]),
        d.dir('other', [
          d.dir('dup', [
            d.file('pubspec.yaml', 'name: dup\nversion: 1.0.0\n'),
          ]),
        ]),
      ]).create();

      final res = await runResolveDir(
        repoPath: p.join(d.sandbox, 'repo'),
        refName: 'dup-v1.0.0',
      );
      expect(res.exitCode, isNonZero);
      expect(res.stderr, contains("Multiple publishable packages named 'dup'"));
    });

    test('fails when monorepo tag does not include package name', () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('pkg_a', [
            d.file('pubspec.yaml', 'name: pkg_a\nversion: 1.0.0\n'),
          ]),
        ]),
      ]).create();

      final res = await runResolveDir(
        repoPath: p.join(d.sandbox, 'repo'),
        refName: 'v1.0.0',
      );
      expect(res.exitCode, isNonZero);
      expect(res.stderr, contains('does not match'));
    });
  });

  group('{package} placeholder expansion', () {
    test('expands {package} and validates name and publish_to', () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('pkg_a', [
            d.file('pubspec.yaml', 'name: pkg_a\nversion: 1.0.0\n'),
          ]),
          d.dir('internal_pkg', [
            d.file(
              'pubspec.yaml',
              'name: internal_pkg\nversion: 1.0.0\npublish_to: none\n',
            ),
          ]),
          d.dir('wrong_dir', [
            d.file('pubspec.yaml', 'name: different_name\nversion: 1.0.0\n'),
          ]),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final ok = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'pkgs/{package}',
        refName: 'pkg_a-v1.0.0',
      );
      expect(ok.exitCode, 0, reason: ok.stderr);
      expect(ok.directory, 'pkgs/pkg_a');

      final unpub = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'pkgs/{package}',
        refName: 'internal_pkg-v1.0.0',
      );
      expect(unpub.exitCode, isNonZero);
      expect(unpub.stderr, contains('publish_to: none'));

      final mismatch = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'pkgs/{package}',
        refName: 'wrong_dir-v1.0.0',
      );
      expect(mismatch.exitCode, isNonZero);
      expect(mismatch.stderr, contains("expected 'wrong_dir'"));

      final badTag = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'pkgs/{package}',
        refName: 'v1.0.0',
      );
      expect(badTag.exitCode, isNonZero);
      expect(badTag.stderr, contains("Cannot expand '{package}'"));
    });
  });

  group('explicit working-directory', () {
    test('allows publish_to: none only when test-run is true', () async {
      await d.dir('repo', [
        d.dir('example', [
          d.file(
            'pubspec.yaml',
            'name: example\nversion: 0.1.0\npublish_to: none\n',
          ),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final testRunOk = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'example',
        refName: 'main',
        testRun: true,
      );
      expect(testRunOk.exitCode, 0, reason: testRunOk.stderr);
      expect(testRunOk.directory, 'example');

      final realRunFail = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'example',
        refName: 'v0.1.0',
        testRun: false,
      );
      expect(realRunFail.exitCode, isNonZero);
      expect(realRunFail.stderr, contains('publish_to: none'));
    });

    test('rejects path traversal outside repository', () async {
      await d.dir('repo', []).create();

      final res = await runResolveDir(
        repoPath: p.join(d.sandbox, 'repo'),
        inputDir: '../outside',
        refName: 'v1.0.0',
      );
      expect(res.exitCode, isNonZero);
      expect(res.stderr, contains('must stay within the repository'));
    });
  });
}

String _extractResolveDirScript(String workflowContent) {
  final lines = workflowContent.split('\n');
  final idIndex = lines.indexWhere((l) => l.trim() == 'id: resolve-dir');
  if (idIndex == -1) {
    throw StateError('Could not find step with id: resolve-dir in publish.yml');
  }

  var runIndex = -1;
  for (var i = idIndex + 1; i < lines.length; i++) {
    final trimmed = lines[i].trimLeft();
    if (trimmed.startsWith('- ')) break;
    if (trimmed == 'run: |') {
      runIndex = i;
      break;
    }
  }
  if (runIndex == -1) {
    throw StateError('Could not find run: | block for resolve-dir');
  }

  final blockLines = <String>[];
  String? indent;
  for (var i = runIndex + 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) {
      blockLines.add('');
      continue;
    }
    if (indent == null) {
      final leadingSpaces = line.length - line.trimLeft().length;
      indent = ' ' * leadingSpaces;
    }
    if (!line.startsWith(indent)) {
      break;
    }
    blockLines.add(line.substring(indent.length));
  }

  return blockLines.join('\n');
}
