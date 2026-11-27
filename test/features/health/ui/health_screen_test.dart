// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-1 (level S): built with API_MODE=mock, the test screen shows the
// example of `GET /v1/health` from the pinned contract.
//
// The expected texts are read from the repository's `contracts/openapi.json`
// (the generated copy of the pinned tag), and that example is checked against
// the pinned tag's own `openapi.json` in test/fixtures/<tag>/.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate_mobile/app/api_mode.dart';
import 'package:tripmate_mobile/app/app.dart';
import 'package:tripmate_mobile/app/flavor.dart';
import 'package:tripmate_mobile/features/health/ui/health_screen.dart';

import '../../../support/contracts.dart';

/// Pumps until [finder] finds a widget, letting real async work (asset
/// loading, the Dio pipeline) run in between. Gives up after about 5 seconds.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets(
    'MF2-1 mock mode: the test screen shows the example of GET /v1/health '
    'from the pinned contract',
    (tester) async {
      final repoContract = readJsonFile(
        '${repoRoot.path}/contracts/openapi.json',
      );
      final pinnedContract = readJsonFile(
        '${pinnedFixtureDir().path}/openapi.json',
      );
      final example = exampleOf(repoContract, 'get', '/v1/health');
      expect(
        example,
        isA<Map<String, dynamic>>(),
        reason: 'contracts/openapi.json has an example for GET /v1/health',
      );
      expect(
        example,
        exampleOf(pinnedContract, 'get', '/v1/health'),
        reason: 'the example is the pinned tag\'s example',
      );
      final health = example! as Map<String, dynamic>;
      final status = health['status'] as String;
      final version = health['version'] as String;

      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const TripMateApp(
          flavor: AppFlavor.dev,
          apiMode: ApiMode.mock,
          initialLocation: HealthScreen.path,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text(version));

      expect(find.byType(HealthScreen), findsOneWidget);
      expect(find.text(status), findsOneWidget);
      expect(find.text(version), findsOneWidget);
    },
  );
}
