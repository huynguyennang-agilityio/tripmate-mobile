import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @authNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue.'**
  String get authNotSignedIn;

  /// No description provided for @authTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get authTokenExpired;

  /// No description provided for @commonAppName.
  ///
  /// In en, this message translates to:
  /// **'TripMate'**
  String get commonAppName;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment and try again.'**
  String get rateLimited;

  /// No description provided for @requestInvalid.
  ///
  /// In en, this message translates to:
  /// **'Some of the details you sent are not valid.'**
  String get requestInvalid;

  /// No description provided for @requestIdempotencyKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'This request needs an Idempotency-Key header.'**
  String get requestIdempotencyKeyRequired;

  /// No description provided for @requestIdempotencyInProgress.
  ///
  /// In en, this message translates to:
  /// **'The same request is still being handled. Try again in a moment.'**
  String get requestIdempotencyInProgress;

  /// No description provided for @requestIdempotencyMismatch.
  ///
  /// In en, this message translates to:
  /// **'This Idempotency-Key was already used for a different request.'**
  String get requestIdempotencyMismatch;

  /// No description provided for @requestFieldMissing.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requestFieldMissing;

  /// No description provided for @requestFieldInvalid.
  ///
  /// In en, this message translates to:
  /// **'This value is not valid.'**
  String get requestFieldInvalid;

  /// No description provided for @requestNotFound.
  ///
  /// In en, this message translates to:
  /// **'This address does not exist.'**
  String get requestNotFound;

  /// No description provided for @requestMethodNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This action is not allowed here.'**
  String get requestMethodNotAllowed;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Try again later.'**
  String get serverError;

  /// No description provided for @serverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'TripMate is not available right now. Try again in a moment.'**
  String get serverUnavailable;

  /// No description provided for @serverNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'This is not available yet. It is coming in a later version.'**
  String get serverNotImplemented;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
