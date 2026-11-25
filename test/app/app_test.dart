// Test cases for card MF1 "Mobile skeleton and CI".
// Test cases: tasks/EPIC-11.md, task MF1.
// Conventions: tripmate-docs/docs/specs/epic-11/spec.md, section 2.11.
//
// MF1-4 (level U): the app started with the `dev` flavor shows
// "TripMate Dev" on its first screen; started with `prod`, it shows
// "TripMate".
//
// In a widget test no native flavor is set, so the flavor is handed to
// the root widget explicitly.

import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate_mobile/app/app.dart';
import 'package:tripmate_mobile/app/flavor.dart';

void main() {
  testWidgets('MF1-4 dev flavor: first screen shows "TripMate Dev"', (
    tester,
  ) async {
    await tester.pumpWidget(const TripMateApp(flavor: AppFlavor.dev));
    await tester.pumpAndSettle();

    expect(find.text('TripMate Dev'), findsWidgets);
  });

  testWidgets('MF1-4 prod flavor: first screen shows "TripMate"', (
    tester,
  ) async {
    await tester.pumpWidget(const TripMateApp(flavor: AppFlavor.prod));
    await tester.pumpAndSettle();

    expect(find.text('TripMate'), findsWidgets);
    expect(find.text('TripMate Dev'), findsNothing);
  });
}
