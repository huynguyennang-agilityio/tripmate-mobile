import 'package:go_router/go_router.dart';

import '../features/health/data/health_repository.dart';
import '../features/health/ui/health_screen.dart';
import '../features/home/ui/home_screen.dart';
import 'flavor.dart';

/// Builds the app's router. Each feature adds its routes here.
///
/// [healthRepository] builds the repository of the health screen when that
/// route opens, so the API client is made only when a screen needs it.
GoRouter buildRouter({
  required AppFlavor flavor,
  required Future<HealthRepository> Function() healthRepository,
  String initialLocation = HomeScreen.path,
}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: HomeScreen.path,
      builder: (context, state) => HomeScreen(flavor: flavor),
    ),
    GoRoute(
      path: HealthScreen.path,
      builder: (context, state) => HealthScreen(repository: healthRepository),
    ),
  ],
);
