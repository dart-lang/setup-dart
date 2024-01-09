// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';

void main(List<String> args) {
  var argsParser = ArgParser()
    ..addFlag(
      'generate',
      negatable: false,
      help: 'Generate the compilation signature to lib/sig.txt.',
    )
    ..addFlag(
      'verify',
      negatable: false,
      help: 'Verify the compilation signature against dist/sig.txt.',
    );

  var argsResult = argsParser.parse(args);

  final generate = argsResult['generate'] as bool;
  final verify = argsResult['verify'] as bool;

  if (!generate && !verify) {
    print('Please specify one of --generate or --verify.\n');
    print(argsParser.usage);
    exit(1);
  }

  var sig = calcSig();

  if (generate) {
    File('lib/sig.txt').writeAsStringSync('$sig\n');
  } else if (verify) {
    var existing = File('dist/sig.txt').readAsStringSync().trim();
    if (existing != sig) {
      stderr.writeln(
          "Compilation artifacts not up-to-date; re-run 'npm run all'.");
      exit(1);
    } else {
      print('Compilation artifacts up-to-date.');
    }
  }
}

String calcSig() {
  final bytes = <int>[];
  for (var file in _files()) {
    bytes.addAll(file.readAsBytesSync());
  }
  return md5.convert(bytes).toString();
}

List<File> _files() {
  // Collect lib/ Dart files.
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
  files.add(File('pubspec.yaml'));
  files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

  return files;
}
