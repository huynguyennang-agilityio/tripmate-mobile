import 'package:flutter/material.dart';

import '../../../app/flavor.dart';

/// The first screen. For now it shows the app's name, which tells the
/// `dev` and `prod` apps apart.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.flavor});

  /// The route of this screen.
  static const String path = '/';

  /// The flavor the app runs as.
  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(flavor.appName)),
      body: Center(
        child: Text(
          flavor.appName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
