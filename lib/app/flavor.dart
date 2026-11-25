import 'package:flutter/foundation.dart';

/// The app flavor: two apps that install side by side on one phone
/// (EPIC-11 spec, section 2.11).
///
/// The native build sets the flavor (`flutter run --flavor dev`); Flutter
/// passes its name to Dart as `appFlavor`.
enum AppFlavor {
  /// Application ID `com.tripmate.app.dev`, name "TripMate Dev". Runs
  /// against the local stack.
  dev(appName: 'TripMate Dev'),

  /// Application ID `com.tripmate.app`, name "TripMate". Runs against
  /// production.
  prod(appName: 'TripMate');

  const AppFlavor({required this.appName});

  /// The name shown on the device and on the first screen.
  final String appName;

  /// The flavor for the native flavor [name] that Flutter reports.
  ///
  /// No name means the app runs without a native flavor. That is allowed
  /// only when [allowMissing] is true, by default in debug mode (for
  /// example in `flutter test`), and is treated as [dev]. In profile and
  /// release builds a missing name is an error, as is an unknown name in
  /// any mode, so a build never runs silently as another flavor.
  static AppFlavor fromName(String? name, {bool allowMissing = kDebugMode}) {
    if (name == null || name.isEmpty) {
      if (allowMissing) {
        return AppFlavor.dev;
      }
      throw ArgumentError.value(name, 'name', 'No app flavor in this build');
    }
    for (final flavor in AppFlavor.values) {
      if (flavor.name == name) {
        return flavor;
      }
    }
    throw ArgumentError.value(name, 'name', 'Unknown app flavor');
  }
}
