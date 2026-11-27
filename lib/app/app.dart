import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmate_api/tripmate_api.dart';

import '../core/api/api_client.dart';
import '../core/api/device_id.dart';
import '../core/api/mock_api.dart';
import '../features/health/data/health_repository.dart';
import '../l10n/app_localizations.dart';
import 'api_mode.dart';
import 'flavor.dart';
import 'router.dart';

/// The root widget of TripMate.
class TripMateApp extends StatefulWidget {
  const TripMateApp({
    super.key,
    required this.flavor,
    this.apiMode = ApiMode.current,
    this.initialLocation = '/',
    this.locale,
  });

  /// The flavor the app runs as.
  final AppFlavor flavor;

  /// Where API requests go. Defaults to the mode of this build.
  final ApiMode apiMode;

  /// The first route.
  final String initialLocation;

  /// A fixed language; null follows the device.
  final Locale? locale;

  @override
  State<TripMateApp> createState() => _TripMateAppState();
}

class _TripMateAppState extends State<TripMateApp> {
  late final GoRouter _router = buildRouter(
    flavor: widget.flavor,
    healthRepository: _healthRepository,
    initialLocation: widget.initialLocation,
  );

  // Built when a screen first needs it, so a screen that calls no API never
  // touches storage or the asset bundle.
  late final Future<Dio> _dio = _createDio();

  Future<Dio> _createDio() async {
    final prefs = await SharedPreferences.getInstance();
    final mock = widget.apiMode == ApiMode.mock
        ? await MockApiInterceptor.fromAsset()
        : null;
    return createDio(
      flavor: widget.flavor,
      mode: widget.apiMode,
      deviceIds: DeviceIdStore(prefs: prefs),
      mock: mock,
    );
  }

  Future<HealthRepository> _healthRepository() async =>
      HealthRepository(DefaultApi(await _dio));

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: widget.flavor.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
