import 'package:tripmate_api/tripmate_api.dart';

/// Reads `GET /v1/health` through the generated client.
class HealthRepository {
  const HealthRepository(this._api);

  final DefaultApi _api;

  Future<Health> read() async {
    final response = await _api.healthV1HealthGet();
    final health = response.data;
    if (health == null) {
      throw StateError('GET /v1/health answered with no body');
    }
    return health;
  }
}
