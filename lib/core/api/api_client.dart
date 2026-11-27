import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app/api_mode.dart';
import '../../app/flavor.dart';
import 'device_id.dart';
import 'idempotency.dart';
import 'mock_api.dart';

/// The production API address, set at build time with
/// `--dart-define=API_BASE_URL=https://...`. No default: the address is not
/// decided yet (EPIC-11 spec, decision on the domain), so a `prod` build
/// without it fails at its first request instead of calling a made-up host.
const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// The base URL of the API for [flavor] on the running platform.
///
/// `dev` runs against the local stack: `10.0.2.2:8000` from the Android
/// emulator, `localhost:8000` elsewhere (the iOS simulator).
String baseUrlFor(AppFlavor flavor) {
  if (_apiBaseUrl.isNotEmpty) {
    return _apiBaseUrl;
  }
  switch (flavor) {
    case AppFlavor.dev:
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000'
          : 'http://localhost:8000';
    case AppFlavor.prod:
      throw StateError(
        'The production API address is not set: build with '
        '--dart-define=API_BASE_URL=<address>.',
      );
  }
}

/// The Dio every API call goes through.
///
/// Sends `X-Device-Id` on every request and `Idempotency-Key` on creates. In
/// mock mode the [mock] interceptor, added last, answers from the contract's
/// examples so nothing reaches the network.
Dio createDio({
  required AppFlavor flavor,
  required ApiMode mode,
  required DeviceIdStore deviceIds,
  MockApiInterceptor? mock,
}) {
  if (mode == ApiMode.mock && mock == null) {
    throw ArgumentError.notNull('mock');
  }
  final dio = Dio(
    BaseOptions(
      baseUrl:
          mode == ApiMode.mock &&
              _apiBaseUrl.isEmpty &&
              flavor == AppFlavor.prod
          ? 'http://localhost:8000'
          : baseUrlFor(flavor),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.addAll([
    DeviceIdInterceptor(deviceIds),
    IdempotencyKeyInterceptor(),
    if (mode == ApiMode.mock) mock!,
  ]);
  return dio;
}
