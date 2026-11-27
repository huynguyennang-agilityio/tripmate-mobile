// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authNotSignedIn => 'Sign in to continue.';

  @override
  String get authTokenExpired => 'Your session has expired. Sign in again.';

  @override
  String get commonAppName => 'TripMate';

  @override
  String get rateLimited => 'Too many requests. Wait a moment and try again.';

  @override
  String get requestInvalid => 'Some of the details you sent are not valid.';

  @override
  String get requestIdempotencyKeyRequired =>
      'This request needs an Idempotency-Key header.';

  @override
  String get requestIdempotencyInProgress =>
      'The same request is still being handled. Try again in a moment.';

  @override
  String get requestIdempotencyMismatch =>
      'This Idempotency-Key was already used for a different request.';

  @override
  String get requestFieldMissing => 'This field is required.';

  @override
  String get requestFieldInvalid => 'This value is not valid.';

  @override
  String get requestNotFound => 'This address does not exist.';

  @override
  String get requestMethodNotAllowed => 'This action is not allowed here.';

  @override
  String get serverError =>
      'Something went wrong on our side. Try again later.';

  @override
  String get serverUnavailable =>
      'TripMate is not available right now. Try again in a moment.';

  @override
  String get serverNotImplemented =>
      'This is not available yet. It is coming in a later version.';
}
