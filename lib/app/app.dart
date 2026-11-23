import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'flavor.dart';
import 'router.dart';

/// The root widget of TripMate.
class TripMateApp extends StatefulWidget {
  const TripMateApp({super.key, required this.flavor});

  /// The flavor the app runs as.
  final AppFlavor flavor;

  @override
  State<TripMateApp> createState() => _TripMateAppState();
}

class _TripMateAppState extends State<TripMateApp> {
  late final GoRouter _router = buildRouter(flavor: widget.flavor);

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
      routerConfig: _router,
    );
  }
}
