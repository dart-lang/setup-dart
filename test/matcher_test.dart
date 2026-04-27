import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

void main() {
  late RegExp bulletRegExp;
  late RegExp dashRegExp;

  setUpAll(() {
    final matcherFile = File('dart-analyzer.json');
    expect(matcherFile.existsSync(), isTrue,
        reason: 'dart-analyzer.json should exist');

    final json = jsonDecode(matcherFile.readAsStringSync()) as Map;
    final matchers = json['problemMatcher'] as List;

    final bulletMatcher = matchers[0] as Map;
    final bulletPattern = (bulletMatcher['pattern'] as List).single as Map;
    bulletRegExp = RegExp(bulletPattern['regexp'] as String);

    final dashMatcher = matchers[1] as Map;
    final dashPattern = (dashMatcher['pattern'] as List).single as Map;
    dashRegExp = RegExp(dashPattern['regexp'] as String);
  });

  group('Bullet Matcher', () {
    test('matches error line', () {
      const line =
          "  error • lib/main.dart:10:20 • The argument type 'String' can't be assigned to the parameter type 'int' • argument_type_not_assignable";
      final match = bulletRegExp.firstMatch(line);

      expect(match, isNotNull);
      expect(match!.group(1), 'error');
      expect(match.group(2), 'lib/main.dart');
      expect(match.group(3), '10');
      expect(match.group(4), '20');
      expect(
          match.group(5),
          "The argument type 'String' can't be assigned to the "
          "parameter type 'int'");
      expect(match.group(6), 'argument_type_not_assignable');
    });

    test('matches warning line', () {
      const line =
          '  warning • lib/file.dart:1:8 • Unused import • unused_import';
      final match = bulletRegExp.firstMatch(line);

      expect(match, isNotNull);
      expect(match!.group(1), 'warning');
      expect(match.group(2), 'lib/file.dart');
      expect(match.group(3), '1');
      expect(match.group(4), '8');
      expect(match.group(5), 'Unused import');
      expect(match.group(6), 'unused_import');
    });

    test('matches info line from user', () {
      const line =
          '   info • test/matcher_test.dart:14:81 • The line length exceeds the 80-character limit. Try breaking the line across multiple lines. • lines_longer_than_80_chars';
      final match = bulletRegExp.firstMatch(line);

      expect(match, isNotNull);
      expect(match!.group(1), 'info');
      expect(match.group(2), 'test/matcher_test.dart');
      expect(match.group(3), '14');
      expect(match.group(4), '81');
      expect(
          match.group(5),
          'The line length exceeds the 80-character limit. Try '
          'breaking the line across multiple lines.');
      expect(match.group(6), 'lines_longer_than_80_chars');
    });
  });

  group('Dash Matcher', () {
    test('matches error line', () {
      const line =
          "      error - bin/main.dart:2:11 - A value of type 'String' can't be assigned to a variable of type 'int'. - invalid_assignment";
      final match = dashRegExp.firstMatch(line);

      expect(match, isNotNull);
      expect(match!.group(1), 'error');
      expect(match.group(2), 'bin/main.dart');
      expect(match.group(3), '2');
      expect(match.group(4), '11');
      expect(
          match.group(5),
          "A value of type 'String' can't be assigned to a "
          "variable of type 'int'.");
      expect(match.group(6), 'invalid_assignment');
    });

    test('matches warning line', () {
      const line =
          "    warning - bin/main.dart:2:7 - The value of the local variable 'x' isn't used. - unused_local_variable";
      final match = dashRegExp.firstMatch(line);

      expect(match, isNotNull);
      expect(match!.group(1), 'warning');
      expect(match.group(2), 'bin/main.dart');
      expect(match.group(3), '2');
      expect(match.group(4), '7');
      expect(match.group(5), "The value of the local variable 'x' isn't used.");
      expect(match.group(6), 'unused_local_variable');
    });
  });

  test('does not match unrelated lines', () {
    const line = 'Analyzing setup-dart...';
    expect(bulletRegExp.firstMatch(line), isNull);
    expect(dashRegExp.firstMatch(line), isNull);
  });

  test('matches real analyzer output', () async {
    // Setup a dummy project with an error
    await d.dir('project', [
      d.file('pubspec.yaml', 'name: project\nenvironment:\n  sdk: ^3.0.0'),
      d.dir('bin', [
        d.file('main.dart', '''
void main() {
  int x = 'string'; // This is an error
}
'''),
      ]),
    ]).create();

    // Run analyzer
    final process = await TestProcess.start(
      Platform.resolvedExecutable,
      ['analyze'],
      workingDirectory: path.join(d.sandbox, 'project'),
    );

    // Wait for process to finish
    await process.shouldExit();

    // Read stdout
    final stdoutLines = await process.stdout.rest.toList();

    print('Analyzer output:');
    for (final line in stdoutLines) {
      print('  $line');
    }

    // Find the error line and verify it matches either regex
    var foundError = false;
    for (final line in stdoutLines) {
      final matchBullet = bulletRegExp.firstMatch(line);
      final matchDash = dashRegExp.firstMatch(line);

      if (matchBullet != null || matchDash != null) {
        foundError = true;
        final match = matchBullet ?? matchDash;
        print('Matched line: $line');
        print('  Matched by: ${matchBullet != null ? "bullet" : "dash"}');
        print('  Severity: ${match!.group(1)}');
        print('  File: ${match.group(2)}'); // Both are group 2 now!
        break;
      }
    }

    expect(foundError, isTrue,
        reason: 'Should have found an error line matching the regex');
  });
}
