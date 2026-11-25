import 'dart:math';
import 'package:go_router/go_router.dart';

import '../features/home/ui/home_screen.dart';
import 'flavor.dart';

/// Builds the app's router. Each feature adds its routes here.
GoRouter buildRouter({required AppFlavor flavor}) => GoRouter(
  routes: [
    GoRoute(
      path: HomeScreen.path,
      builder: (context, state) => HomeScreen(flavor: flavor),
    ),
  ],
);
