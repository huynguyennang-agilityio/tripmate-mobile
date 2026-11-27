import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// The id of this installation, sent as `X-Device-Id` on every request
/// (EPIC-11 spec, section 2.11).
///
/// The first read makes a UUID v4 and saves it; later reads, also after the
/// app restarts, return the same value. Await [ensureSaved] once at startup
/// (where the client is built) so the id is on disk before the first request.
class DeviceIdStore {
  DeviceIdStore({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _key = 'device_id';

  final SharedPreferences _prefs;

  Future<bool>? _pendingWrite;

  /// Reads (or makes) the id and completes when it is saved. A failed save
  /// is not fatal: the id stays in memory for this run and the next start
  /// makes a new one.
  Future<void> ensureSaved() async {
    deviceId;
    try {
      await _pendingWrite;
    } on Object {
      // Nothing to do; see above.
    }
  }

  String get deviceId {
    final saved = _prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    final created = const Uuid().v4();
    // SharedPreferences keeps the value in memory at once, so later reads
    // return it; the write to disk is awaited in [ensureSaved].
    _pendingWrite = _prefs.setString(_key, created);
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
