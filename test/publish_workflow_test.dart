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
  late List<String> resolveStepScripts;
  late String resolveStepScript;

  setUpAll(() {
    final workflowFile = File('.github/workflows/publish.yml');
    expect(workflowFile.existsSync(), isTrue);
    workflowText = workflowFile.readAsStringSync();
    resolveStepScripts = _extractResolveDirScripts(workflowText);
    expect(resolveStepScripts, hasLength(2));
    resolveStepScript = resolveStepScripts.first;
  });

  test('publish.yml resolves directory independently in validate and package',
      () {
    expect(resolveStepScripts[1], equals(resolveStepScripts[0]));
    expect(workflowText, isNot(contains('    outputs:')));
    expect(workflowText, isNot(contains('needs.validate.outputs')));
    expect(
      workflowText,
      contains(
        'working-directory: \${{ steps.resolve-dir.outputs.directory }}',
      ),
    );
    expect(
      workflowText,
      contains('PKG_DIR: \${{ steps.resolve-dir.outputs.directory }}'),
    );
  });

  Future<({int exitCode, String? directory, String stdout, String stderr})>
      runResolveDir({
    required String repoPath,
    String inputDir = '.',
    String refName = 'v1.0.0',
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

    test('validates tag format and pubspec existence', () async {
      await d.dir('repo', [
        d.dir('pkgs', [
          d.dir('pkg_a', [
            d.file('pubspec.yaml', 'name: pkg_a\nversion: 1.0.0\n'),
          ]),
        ]),
      ]).create();

      final repoPath = p.join(d.sandbox, 'repo');

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
    });
  });

  group('explicit working-directory', () {
    test('resolves explicit subdirectory', () async {
      await d.dir('repo', [
        d.dir('example', [
          d.file(
            'pubspec.yaml',
            'name: example\nversion: 0.1.0\npublish_to: none\n',
          ),
        ]),
      ]).create();

      final res = await runResolveDir(
        repoPath: p.join(d.sandbox, 'repo'),
        inputDir: 'example',
        refName: 'main',
      );
      expect(res.exitCode, 0, reason: res.stderr);
      expect(res.directory, 'example');
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

List<String> _extractResolveDirScripts(String workflowContent) {
  final lines = workflowContent.split('\n');
  final scripts = <String>[];

  for (var idIndex = 0; idIndex < lines.length; idIndex++) {
    if (lines[idIndex].trim() != 'id: resolve-dir') continue;

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

    scripts.add(blockLines.join('\n'));
  }

  return scripts;
}
