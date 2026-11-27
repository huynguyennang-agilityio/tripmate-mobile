// Helpers for the MF2 tests that read the contract files.
//
// `flutter test` runs with the package root as the current directory, so
// every path here is relative to the repository root.
//
// - `CONTRACTS_VERSION` names the pinned `tripmate-contracts` tag
//   (test/INTERFACE.md).
// - `contracts/` is the repository's generated copy of that tag.
// - `test/fixtures/<tag>/` is a copy of the same tag's `openapi.json` and
//   `translations/`, extracted with
//   `git -C ../tripmate-contracts archive <tag> openapi.json translations`.
//   The tests use it as the pinned contract without the network.

import 'dart:convert';
import 'dart:io';

/// The repository root.
Directory get repoRoot => Directory.current;

/// The pinned tag, read from `CONTRACTS_VERSION`.
String readPinnedVersion() =>
    File('${repoRoot.path}/CONTRACTS_VERSION').readAsStringSync().trim();

/// The test fixture holding the pinned tag's files.
///
/// Fails with a clear message when the fixture for the pinned tag is missing,
/// for example after `CONTRACTS_VERSION` moved to a new tag.
Directory pinnedFixtureDir() {
  final version = readPinnedVersion();
  final dir = Directory('${repoRoot.path}/test/fixtures/$version');
  if (!dir.existsSync()) {
    throw StateError(
      'No fixture for the pinned tag $version: extract it into ${dir.path}',
    );
  }
  return dir;
}

/// Reads and parses the JSON file at [path].
Map<String, dynamic> readJsonFile(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// Follows a local `$ref` such as `#/components/schemas/Health` in [doc].
Map<String, dynamic> _resolve(
  Map<String, dynamic> doc,
  Map<String, dynamic> node,
) {
  var current = node;
  while (current[r'$ref'] is String) {
    final ref = current[r'$ref'] as String;
    if (!ref.startsWith('#/')) {
      throw StateError('Only local refs are supported: $ref');
    }
    Object? target = doc;
    for (final part in ref.substring(2).split('/')) {
      target = (target as Map<String, dynamic>)[part];
    }
    current = target! as Map<String, dynamic>;
  }
  return current;
}

/// The example the contract [doc] gives for the `application/json` answer of
/// its lowest 2xx response of [method] [path], in the order of
/// test/INTERFACE.md: the media type's `example`, else the first value of its
/// `examples`, else the schema's `example`, else the first item of the
/// schema's `examples` (a `$ref` schema is followed).
///
/// Returns null when the operation has no example.
Object? exampleOf(Map<String, dynamic> doc, String method, String path) {
  final paths = doc['paths'] as Map<String, dynamic>;
  final operation =
      (paths[path] as Map<String, dynamic>)[method.toLowerCase()]
          as Map<String, dynamic>;
  final responses = operation['responses'] as Map<String, dynamic>;
  final codes =
      responses.keys.where((code) => RegExp(r'^2\d\d$').hasMatch(code)).toList()
        ..sort();
  for (final code in codes) {
    final response = _resolve(doc, responses[code] as Map<String, dynamic>);
    final content = response['content'] as Map<String, dynamic>?;
    final media = content?['application/json'] as Map<String, dynamic>?;
    if (media == null) {
      continue;
    }
    if (media.containsKey('example')) {
      return media['example'];
    }
    final mediaExamples = media['examples'] as Map<String, dynamic>?;
    if (mediaExamples != null && mediaExamples.isNotEmpty) {
      final first = _resolve(
        doc,
        mediaExamples.values.first as Map<String, dynamic>,
      );
      return first['value'];
    }
    final schemaNode = media['schema'] as Map<String, dynamic>?;
    if (schemaNode == null) {
      return null;
    }
    final schema = _resolve(doc, schemaNode);
    if (schema.containsKey('example')) {
      return schema['example'];
    }
    final schemaExamples = schema['examples'] as List<dynamic>?;
    if (schemaExamples != null && schemaExamples.isNotEmpty) {
      return schemaExamples.first;
    }
    return null;
  }
  return null;
}
