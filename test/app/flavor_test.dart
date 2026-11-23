import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate_mobile/app/flavor.dart';

void main() {
  group('AppFlavor', () {
    test('has the app names of the spec', () {
      expect(AppFlavor.dev.appName, 'TripMate Dev');
      expect(AppFlavor.prod.appName, 'TripMate');
    });

    test('fromName reads the native flavor names', () {
      expect(AppFlavor.fromName('dev'), AppFlavor.dev);
      expect(AppFlavor.fromName('prod'), AppFlavor.prod);
    });

    test('fromName treats no flavor as dev', () {
      expect(AppFlavor.fromName(null), AppFlavor.dev);
      expect(AppFlavor.fromName(''), AppFlavor.dev);
    });

    test('fromName refuses an unknown flavor', () {
      expect(() => AppFlavor.fromName('staging'), throwsArgumentError);
    });
  });
}
