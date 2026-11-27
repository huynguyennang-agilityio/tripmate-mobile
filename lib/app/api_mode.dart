/// Where API requests go (EPIC-11 spec, section 2.11).
///
/// Set at build time with `--dart-define=API_MODE=mock`; any other value,
/// or none, means [real]. The mock interceptor that answers from the
/// contract's examples is `MockApiInterceptor` (lib/core/api/mock_api.dart).
enum ApiMode {
  /// Requests go to the backend of the flavor.
  real,

  /// Requests are answered from the pinned contract's examples.
  mock;

  /// The mode this build was made with.
  static const ApiMode current = String.fromEnvironment('API_MODE') == 'mock'
      ? ApiMode.mock
      : ApiMode.real;

  /// The mode for a raw `API_MODE` [value].
  static ApiMode fromValue(String value) =>
      value == 'mock' ? ApiMode.mock : ApiMode.real;
}
