import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/health_repository.dart';
import '../logic/health_cubit.dart';

/// A test screen: it reads `GET /v1/health` and shows the `status` and
/// `version` values, in both the real and the mock mode (task MF2).
///
/// It shows the values only: no translation key names its labels.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key, required this.repository});

  /// The route of this screen.
  static const String path = '/health';

  /// The repository, ready once the API client has been built.
  final Future<HealthRepository> Function() repository;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late final Future<HealthCubit> _cubit = _createCubit();

  Future<HealthCubit> _createCubit() async {
    final cubit = HealthCubit(await widget.repository());
    unawaited(cubit.load());
    return cubit;
  }

  @override
  void dispose() {
    _cubit.then((cubit) => cubit.close(), onError: (Object _) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<HealthCubit>(
          future: _cubit,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Icon(Icons.error_outline);
            }
            final cubit = snapshot.data;
            if (cubit == null) {
              return const CircularProgressIndicator();
            }
            return BlocBuilder<HealthCubit, HealthState>(
              bloc: cubit,
              builder: (context, state) => switch (state) {
                HealthLoading() => const CircularProgressIndicator(),
                HealthFailed() => const Icon(Icons.error_outline),
                HealthLoaded(:final health) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text(health.status), Text(health.version)],
                ),
              },
            );
          },
        ),
      ),
    );
  }
}
