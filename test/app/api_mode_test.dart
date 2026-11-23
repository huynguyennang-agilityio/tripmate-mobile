import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate_mobile/app/api_mode.dart';

void main() {
  group('ApiMode', () {
    test('is real when API_MODE is not set', () {
      // `flutter test` runs without --dart-define=API_MODE.
      expect(ApiMode.current, ApiMode.real);
    });

    test('fromValue reads mock', () {
      expect(ApiMode.fromValue('mock'), ApiMode.mock);
    });

    test('fromValue treats any other value as real', () {
      expect(ApiMode.fromValue(''), ApiMode.real);
      expect(ApiMode.fromValue('real'), ApiMode.real);
      expect(ApiMode.fromValue('MOCK'), ApiMode.real);
    });
  });
}
