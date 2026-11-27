// Test cases for card MF2 "Mobile API client and mock mode".
// Test cases: tasks/EPIC-11.md, task MF2. Interface: test/INTERFACE.md.
//
// MF2-7 (level S): a widget test of one message key: the key shows its text
// in Vietnamese and in English.
//
// The key is `auth.not_signed_in`, generated as `authNotSignedIn`. The
// expected texts are read from the repository's `contracts/translations/`
// (the generated copy of the pinned tag) and checked against the pinned
// tag's own files in test/fixtures/<tag>/translations/.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate_mobile/l10n/app_localizations.dart';

import '../support/contracts.dart';

const _key = 'auth.not_signed_in';

/// The text of [_key] in [lang], from the repository's generated copy, after
/// checking it is the pinned tag's text.
String expectedText(String lang) {
  final repoText =
      readJsonFile(
            '${repoRoot.path}/contracts/translations/$lang/auth.json',
          )[_key]
          as String?;
  final pinnedText =
      readJsonFile(
            '${pinnedFixtureDir().path}/translations/$lang/auth.json',
          )[_key]
          as String?;
  expect(repoText, isNotNull, reason: '$_key exists in $lang');
  expect(repoText, pinnedText, reason: 'the $lang text is the pinned text');
  return repoText!;
}

Widget appIn(Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => Text(
      Localizations.of<AppLocalizations>(
        context,
        AppLocalizations,
      )!.authNotSignedIn,
    ),
  ),
);

void main() {
  test('MF2-7 the app supports Vietnamese and English', () {
    final languages = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    expect(languages, containsAll(<String>['vi', 'en']));
  });

  testWidgets('MF2-7 auth.not_signed_in shows its Vietnamese text', (
    tester,
  ) async {
    final text = expectedText('vi');
    await tester.pumpWidget(appIn(const Locale('vi')));
    await tester.pumpAndSettle();

    expect(find.text(text), findsOneWidget);
  });

  testWidgets('MF2-7 auth.not_signed_in shows its English text', (
    tester,
  ) async {
    final text = expectedText('en');
    await tester.pumpWidget(appIn(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text(text), findsOneWidget);
  });
}
