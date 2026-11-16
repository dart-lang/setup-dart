// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
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

  group('{package} placeholder expansion', () {
    test('expands pkgs/{package} and {package} from release tags', () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('pkg_a', [
            d.file('pubspec.yaml', 'name: pkg_a\nversion: 1.0.0\n'),
          ]),
        ]),
        d.dir('webdev', [
          d.file('pubspec.yaml', 'name: webdev\nversion: 3.0.0-dev.1\n'),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final pkgsRes = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'pkgs/{package}',
        refName: 'pkg_a-v1.0.0',
      );
      expect(pkgsRes.exitCode, 0, reason: pkgsRes.stderr);
      expect(pkgsRes.directory, 'pkgs/pkg_a');

      final topLevelRes = await runResolveDir(
        repoPath: repoPath,
        inputDir: '{package}',
        refName: 'webdev-v3.0.0-dev.1',
      );
      expect(topLevelRes.exitCode, 0, reason: topLevelRes.stderr);
      expect(topLevelRes.directory, 'webdev');
    });

    test(
      'validates tag format, pubspec existence, name, and publish_to',
      () async {
        await d.dir('repo', [
          d.dir('pkgs', [
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
        expect(mismatch.stderr, contains("does not match 'wrong_dir'"));

        final missing = await runResolveDir(
          repoPath: repoPath,
          inputDir: 'pkgs/{package}',
          refName: 'missing-v1.0.0',
        );
        expect(missing.exitCode, isNonZero);
        expect(missing.stderr, contains('No pubspec.yaml found'));

        final badTag = await runResolveDir(
          repoPath: repoPath,
          inputDir: 'pkgs/{package}',
          refName: 'v1.0.0',
        );
        expect(badTag.exitCode, isNonZero);
        expect(badTag.stderr, contains("Cannot expand '{package}'"));
      },
    );
  });

  group('glob patterns with {package}', () {
    test('supports federated plugin layout packages/*/{package}', () async {
      await d.dir('repo', [
        d.dir('packages', [
          d.dir('camera', [
            d.dir('camera', [
              d.file('pubspec.yaml', 'name: camera\nversion: 1.0.0\n'),
            ]),
            d.dir('camera_android', [
              d.file('pubspec.yaml', 'name: camera_android\nversion: 1.2.0\n'),
            ]),
          ]),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

      final appFacing = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'packages/*/{package}',
        refName: 'camera-v1.0.0',
      );
      expect(appFacing.exitCode, 0, reason: appFacing.stderr);
      expect(appFacing.directory, 'packages/camera/camera');

      final androidImpl = await runResolveDir(
        repoPath: repoPath,
        inputDir: 'packages/*/{package}',
        refName: 'camera_android-v1.2.0',
      );
      expect(androidImpl.exitCode, 0, reason: androidImpl.stderr);
      expect(androidImpl.directory, 'packages/camera/camera_android');
    });

    test(
      'supports mixed-depth monorepos (**/{package}) and skips nested fixtures',
      () async {
        await d.dir('repo', [
          d.file('pubspec.yaml', 'name: _workspace\npublish_to: none\n'),
          d.dir('build', [
            d.file('pubspec.yaml', 'name: build\nversion: 4.0.0\n'),
          ]),
          d.dir('build_runner', [
            d.file('pubspec.yaml', 'name: build_runner\nversion: 2.5.0\n'),
            d.dir('test', [
              d.dir('fixtures', [
                d.dir('build', [
                  d.file('pubspec.yaml', 'name: build\nversion: 0.0.1\n'),
                ]),
              ]),
            ]),
          ]),
          d.dir('builder_pkgs', [
            d.dir('build_web_compilers', [
              d.file(
                'pubspec.yaml',
                'name: build_web_compilers\nversion: 4.1.0\n',
              ),
            ]),
          ]),
          d.dir('built_types', [
            d.dir('built_value', [
              d.file('pubspec.yaml', 'name: built_value\nversion: 8.9.0\n'),
            ]),
          ]),
        ]).create();

        final repoPath = p.join(d.sandbox, 'repo');

        final depth1 = await runResolveDir(
          repoPath: repoPath,
          inputDir: '**/{package}',
          refName: 'build-v4.0.0',
        );
        expect(depth1.exitCode, 0, reason: depth1.stderr);
        expect(depth1.directory, 'build');

        final depth2a = await runResolveDir(
          repoPath: repoPath,
          inputDir: '**/{package}',
          refName: 'build_web_compilers-v4.1.0',
        );
        expect(depth2a.exitCode, 0, reason: depth2a.stderr);
        expect(depth2a.directory, 'builder_pkgs/build_web_compilers');

        final depth2b = await runResolveDir(
          repoPath: repoPath,
          inputDir: '**/{package}',
          refName: 'built_value-v8.9.0',
        );
        expect(depth2b.exitCode, 0, reason: depth2b.stderr);
        expect(depth2b.directory, 'built_types/built_value');
      },
    );

    test('fails when glob matches multiple publishable packages', () async {
      await d.dir('repo', [
        d.dir('group_a', [
          d.dir('dup', [d.file('pubspec.yaml', 'name: dup\nversion: 1.0.0\n')]),
        ]),
        d.dir('group_b', [
          d.dir('dup', [d.file('pubspec.yaml', 'name: dup\nversion: 1.0.0\n')]),
        ]),
      ]).create();

      final res = await runResolveDir(
        repoPath: p.join(d.sandbox, 'repo'),
        inputDir: '*/{package}',
        refName: 'dup-v1.0.0',
      );
      expect(res.exitCode, isNonZero);
      expect(res.stderr, contains('matched multiple publishable packages'));
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

      final repoPath = p.join(d.sandbox, 'repo');

      for (final badDir in [
        '..',
        '../outside',
        'pkgs/../../outside',
        '/',
        '/etc',
      ]) {
        final res = await runResolveDir(
          repoPath: repoPath,
          inputDir: badDir,
          refName: 'v1.0.0',
        );
        expect(res.exitCode, isNonZero, reason: 'Expected failure for $badDir');
        expect(res.stderr, contains('must stay within the repository'));
      }
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
