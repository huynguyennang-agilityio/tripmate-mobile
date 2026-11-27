import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Gives each create (`POST`) an `Idempotency-Key`, a new UUID v4 unless the
/// request has one already.
///
/// The key is written into the request's own headers, so a retry that sends
/// the same `RequestOptions` again (`dio.fetch(error.requestOptions)`) carries
/// the same key (EPIC-11 spec, section 2.11).
class IdempotencyKeyInterceptor extends Interceptor {
  IdempotencyKeyInterceptor();

  static const String header = 'Idempotency-Key';
  static const Uuid _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'POST' &&
        !options.headers.keys.any(
          (k) => k.toLowerCase() == 'idempotency-key',
        )) {
      options.headers[header] = _uuid.v4();
    }
    handler.next(options);
  }
}
