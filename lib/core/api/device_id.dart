import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// The id of this installation, sent as `X-Device-Id` on every request
/// (EPIC-11 spec, section 2.11).
///
/// The first read makes a UUID v4 and saves it; later reads, also after the
/// app restarts, return the same value.
class DeviceIdStore {
  DeviceIdStore({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _key = 'device_id';

  final SharedPreferences _prefs;

  String get deviceId {
    final saved = _prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    final created = const Uuid().v4();
    // The write is not awaited: the value is kept in memory at once, and a
    // failed save only means the next start makes a new id.
    _prefs.setString(_key, created);
    return created;
  }
}

/// Sets `X-Device-Id` on every request.
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor(this._store);

  final DeviceIdStore _store;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Device-Id'] = _store.deviceId;
    handler.next(options);
  }
}
