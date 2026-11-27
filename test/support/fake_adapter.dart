// A Dio HTTP adapter for the MF2 unit tests: it records the headers of every
// request that reaches the network and answers without any network.

import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers the [index]-th request (from 0) that reaches the adapter with a
/// status code.
typedef StatusFor = int Function(int index, RequestOptions options);

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter({StatusFor? statusFor})
    : _statusFor = statusFor ?? ((_, _) => 200);

  final StatusFor _statusFor;

  /// The headers of each request that reached the adapter, in order.
  final List<Map<String, dynamic>> headers = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = headers.length;
    headers.add(Map<String, dynamic>.of(options.headers));
    return ResponseBody.fromString(
      '{}',
      _statusFor(index, options),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// The value of header [name] in [headers], whatever the case of its key.
String? headerValue(Map<String, dynamic> headers, String name) {
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) {
      final value = entry.value;
      if (value is List) {
        return value.isEmpty ? null : value.first.toString();
      }
      return value?.toString();
    }
  }
  return null;
}
