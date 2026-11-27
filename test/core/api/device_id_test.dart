// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-3 (level U): any request carries `X-Device-Id`, the same value after
// the app restarts. A restart is `SharedPreferences.resetStatic()` and a new
// `SharedPreferences` instance, `DeviceIdStore`, and Dio.
//
// The contract (contracts/openapi.json, parameter `DeviceId`) gives the
// header as a UUID.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate_mobile/core/api/device_id.dart';

import '../../support/fake_adapter.dart';

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// A Dio as the app builds one at start: over a fresh `SharedPreferences`.
Future<(Dio, RecordingAdapter)> startApp() async {
  final prefs = await SharedPreferences.getInstance();
  final adapter = RecordingAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'))
    ..httpClientAdapter = adapter
    ..interceptors.add(DeviceIdInterceptor(DeviceIdStore(prefs: prefs)));
  return (dio, adapter);
}

void main() {
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('MF2-3 every request carries X-Device-Id, the same value after the app '
      'restarts', () async {
    final (dio, adapter) = await startApp();
    await dio.get<Object?>('/v1/health');
    await dio.post<Object?>('/v1/trips', data: {'name': 'Hanoi'});
    await dio.delete<Object?>('/v1/trips/1');

    expect(adapter.headers, hasLength(3));
    final first = headerValue(adapter.headers[0], 'X-Device-Id');
    expect(first, isNotNull);
    expect(first, matches(_uuid));
    for (final headers in adapter.headers) {
      expect(headerValue(headers, 'X-Device-Id'), first);
    }

    // The app restarts.
    SharedPreferences.resetStatic();
    final (restarted, restartedAdapter) = await startApp();
    await restarted.get<Object?>('/v1/health');
    await restarted.post<Object?>('/v1/trips', data: {'name': 'Hue'});

    expect(restartedAdapter.headers, hasLength(2));
    for (final headers in restartedAdapter.headers) {
      expect(headerValue(headers, 'X-Device-Id'), first);
    }
  });
}
