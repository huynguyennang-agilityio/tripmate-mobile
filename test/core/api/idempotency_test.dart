// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-4 (level U): a create request that is retried: both attempts carry the
// same `Idempotency-Key`. The first attempt fails with 500; the retry sends
// the same request again with `dio.fetch(error.requestOptions)`.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate_mobile/core/api/idempotency.dart';

import '../../support/fake_adapter.dart';

void main() {
  test('MF2-4 a create request that is retried: both attempts carry the same '
      'Idempotency-Key', () async {
    // The first request fails with 500, every later one succeeds.
    final adapter = RecordingAdapter(
      statusFor: (index, _) => index == 0 ? 500 : 201,
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
      ..httpClientAdapter = adapter
      ..interceptors.add(IdempotencyKeyInterceptor());

    DioException? failure;
    try {
      await dio.post<Object?>('/v1/trips', data: {'name': 'Hanoi'});
    } on DioException catch (error) {
      failure = error;
    }
    expect(failure, isNotNull, reason: 'the first attempt fails with 500');
    expect(failure!.response?.statusCode, 500);

    final retry = await dio.fetch<Object?>(failure.requestOptions);
    expect(retry.statusCode, 201);

    expect(adapter.headers, hasLength(2));
    final firstKey = headerValue(adapter.headers[0], 'Idempotency-Key');
    final secondKey = headerValue(adapter.headers[1], 'Idempotency-Key');
    expect(firstKey, isNotNull);
    expect(firstKey, isNotEmpty);
    expect(secondKey, firstKey);
  });
}
