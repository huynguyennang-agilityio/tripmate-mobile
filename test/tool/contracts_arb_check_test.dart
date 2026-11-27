// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-8 (level C, error): the generated ARB files do not match the pinned
// contracts version: the check fails.
//
// Each test runs `dart run tool/contracts.dart check --root <copy> --source
// <pinned files>` against a temporary copy of the repository:
// - baseline: the untouched copy passes, so a failure below comes from the
//   change it makes;
// - `lib/l10n/app_vi.arb` is changed by hand;
// - the ARB files were generated from other translations than the pinned
//   ones.
// The check needs Java (see test/support/contracts_tool.dart).

@Timeout(Duration(minutes: 10))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/contracts_tool.dart';

const _viArb = 'lib/l10n/app_vi.arb';

/// Reads the JSON object in [file].
Map<String, dynamic> readObject(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

/// Writes [object] into [file] as indented JSON.
void writeObject(File file, Map<String, dynamic> object) =>
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(object));

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

  test('MF2-8 baseline: an untouched copy matches the pinned contracts '
      'version and the check passes', () async {
    final run = await runCheck(root: root, source: source);

    expect(run.exitCode, 0, reason: '$run');
  });

  test('MF2-8 lib/l10n/app_vi.arb changed by hand: the check fails and names '
      'the file', () async {
    final arb = File('${root.path}/$_viArb');
    expect(arb.existsSync(), isTrue, reason: '$_viArb exists');
    final messages = readObject(arb);
    final key = messages.keys.firstWhere((k) => !k.startsWith('@'));
    messages[key] = '${messages[key]} (tampered)';
    writeObject(arb, messages);

    final run = await runCheck(root: root, source: source);

    expect(run.exitCode, isNot(0), reason: '$run');
    expect(run.output, contains(_viArb), reason: '$run');
  });

  test('MF2-8 the ARB files were generated from other translations than the '
      'pinned ones: the check fails and names app_vi.arb', () async {
    // The pinned Vietnamese text of one key changes, so the ARB file
    // generated from it differs from the copy's.
    final auth = File('${source.path}/translations/vi/auth.json');
    final messages = readObject(auth);
    final key = messages.keys.first;
    messages[key] = '${messages[key]} (changed)';
    writeObject(auth, messages);

    final run = await runCheck(root: root, source: source);

    expect(run.exitCode, isNot(0), reason: '$run');
    expect(run.output, contains(_viArb), reason: '$run');
  });
}
