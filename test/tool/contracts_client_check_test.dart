// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-6 (level C, error): the generated client does not match the pinned
// contracts version: the check fails.
//
// Each test runs `dart run tool/contracts.dart check --root <copy> --source
// <pinned files>` against a temporary copy of the repository:
// - baseline: the untouched copy passes, so a failure below comes from the
//   change it makes;
// - a generated client file is changed by hand;
// - the client was generated from other contracts than the pinned ones.
// The check needs Java (see test/support/contracts_tool.dart).

@Timeout(Duration(minutes: 10))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/contracts_tool.dart';

/// The generated client's Dart files in [root], sorted by path.
List<File> clientFiles(Directory root) {
  final lib = Directory('${root.path}/packages/tripmate_api/lib');
  expect(lib.existsSync(), isTrue, reason: '${lib.path} exists');
  final files =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  expect(files, isNotEmpty, reason: 'the generated client has Dart files');
  return files;
}

void main() {
  late Directory root;
  late Directory source;

  setUp(() {
    root = copyRepo();
    source = copyPinnedSource();
  });

  tearDown(() {
    root.deleteSync(recursive: true);
    source.deleteSync(recursive: true);
  });

  test('MF2-6 baseline: an untouched copy matches the pinned contracts '
      'version and the check passes', () async {
    final run = await runCheck(root: root, source: source);

    expect(run.exitCode, 0, reason: '$run');
  });

  test('MF2-6 a generated client file changed by hand: the check fails and '
      'names the file', () async {
    final file = clientFiles(root).first;
    final path = relativePath(root, file);
    tamper(file);

    final run = await runCheck(root: root, source: source);

    expect(run.exitCode, isNot(0), reason: '$run');
    expect(run.output, contains(path), reason: '$run');
  });

  test('MF2-6 the client was generated from other contracts than the pinned '
      'ones: the check fails and names the client', () async {
    // The pinned contracts gain a field in the Health schema, so the client
    // generated from them has a different Health model than the copy holds.
    final openapi = File('${source.path}/openapi.json');
    final doc = jsonDecode(openapi.readAsStringSync()) as Map<String, dynamic>;
    final health =
        ((doc['components'] as Map<String, dynamic>)['schemas']
                as Map<String, dynamic>)['Health']
            as Map<String, dynamic>;
    (health['properties'] as Map<String, dynamic>)['uptimeSeconds'] = {
      'title': 'Uptimeseconds',
      'type': 'integer',
    };
    openapi.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(doc));

    final run = await runCheck(root: root, source: source);

    expect(run.exitCode, isNot(0), reason: '$run');
    expect(run.output, contains('packages/tripmate_api/lib/'), reason: '$run');
  });
}
