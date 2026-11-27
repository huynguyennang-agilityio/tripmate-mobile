import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

/// The operation has no example in the contract, so the mock refuses to
/// answer instead of making data up.
class MissingExampleError implements Exception {
  const MissingExampleError(this.operationId);

  final String operationId;

  @override
  String toString() => 'MissingExampleError: no example for $operationId';
}

/// Answers requests from the examples of the pinned contract
/// (`contracts/openapi.json`), without any network (EPIC-11 spec, 2.11).
///
/// The answer is the example of the operation's lowest 2xx response with
/// `application/json` content: the media type's `example`, else the first of
/// its `examples`, else the schema's `example`, else the first of the
/// schema's `examples`. An operation with no example is rejected with a
/// [MissingExampleError] naming its `operationId`.
class MockApiInterceptor extends Interceptor {
  MockApiInterceptor(this._contract);

  /// Reads the contract from the app's assets.
  static Future<MockApiInterceptor> fromAsset() async {
    final text = await rootBundle.loadString('contracts/openapi.json');
    return MockApiInterceptor(jsonDecode(text) as Map<String, dynamic>);
  }

  final Map<String, dynamic> _contract;

  static const _methods = {
    'get',
    'put',
    'post',
    'delete',
    'options',
    'head',
    'patch',
    'trace',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toLowerCase();
    final operation = _operationFor(method, options.uri.path);
    if (operation == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          message:
              'The contract has no operation for '
              '${options.method} ${options.uri.path}',
        ),
        false,
      );
      return;
    }
    final operationId =
        operation['operationId'] as String? ?? '$method ${options.uri.path}';
    final answer = _answerOf(operation);
    if (answer == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: MissingExampleError(operationId),
          message: 'The contract has no example for $operationId',
        ),
        false,
      );
      return;
    }
    handler.resolve(
      Response<Object?>(
        requestOptions: options,
        statusCode: answer.status,
        data: answer.example,
      ),
    );
  }

  Map<String, dynamic>? _operationFor(String method, String path) {
    final paths = _contract['paths'] as Map<String, dynamic>? ?? const {};
    if (!_methods.contains(method)) {
      return null;
    }
    final segments = _segments(path);
    // A path with no template wins over one with a template.
    Map<String, dynamic>? templated;
    for (final entry in paths.entries) {
      final item = entry.value as Map<String, dynamic>;
      final operation = item[method] as Map<String, dynamic>?;
      if (operation == null) {
        continue;
      }
      final template = _segments(entry.key);
      if (template.length != segments.length) {
        continue;
      }
      var matches = true;
      var hasParameter = false;
      for (var i = 0; i < template.length; i++) {
        final part = template[i];
        if (part.startsWith('{') && part.endsWith('}')) {
          hasParameter = true;
        } else if (part != segments[i]) {
          matches = false;
          break;
        }
      }
      if (!matches) {
        continue;
      }
      if (!hasParameter) {
        return operation;
      }
      templated ??= operation;
    }
    return templated;
  }

  List<String> _segments(String path) =>
      path.split('/').where((s) => s.isNotEmpty).toList();

  ({int status, Object? example})? _answerOf(Map<String, dynamic> operation) {
    final responses =
        operation['responses'] as Map<String, dynamic>? ?? const {};
    final codes =
        responses.keys.where((c) => RegExp(r'^2\d\d$').hasMatch(c)).toList()
          ..sort();
    for (final code in codes) {
      final response = _resolve(responses[code] as Map<String, dynamic>);
      final content = response['content'] as Map<String, dynamic>?;
      final media = content?['application/json'] as Map<String, dynamic>?;
      if (media == null) {
        continue;
      }
      // Only the lowest 2xx response with JSON content answers.
      final example = _exampleOf(media);
      return example == null
          ? null
          : (status: int.parse(code), example: example.value);
    }
    return null;
  }

  /// The example of a media type, wrapped so a JSON `null` can be told from
  /// no example.
  ({Object? value})? _exampleOf(Map<String, dynamic> media) {
    if (media.containsKey('example')) {
      return (value: media['example']);
    }
    final examples = media['examples'] as Map<String, dynamic>?;
    if (examples != null && examples.isNotEmpty) {
      final first = _resolve(examples.values.first as Map<String, dynamic>);
      if (first.containsKey('value')) {
        return (value: first['value']);
      }
    }
    final schemaNode = media['schema'] as Map<String, dynamic>?;
    if (schemaNode == null) {
      return null;
    }
    final schema = _resolve(schemaNode);
    if (schema.containsKey('example')) {
      return (value: schema['example']);
    }
    final schemaExamples = schema['examples'] as List<dynamic>?;
    if (schemaExamples != null && schemaExamples.isNotEmpty) {
      return (value: schemaExamples.first);
    }
    return null;
  }

  /// Follows local `$ref`s such as `#/components/schemas/Health`.
  Map<String, dynamic> _resolve(Map<String, dynamic> node) {
    var current = node;
    var hops = 0;
    while (current[r'$ref'] is String) {
      final ref = current[r'$ref'] as String;
      if (!ref.startsWith('#/') || ++hops > 32) {
        throw StateError('Unsupported or circular reference: $ref');
      }
      Object? target = _contract;
      for (final part in ref.substring(2).split('/')) {
        target = (target as Map<String, dynamic>)[part];
      }
      current = target! as Map<String, dynamic>;
    }
    return current;
  }
}
