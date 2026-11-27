import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate_api/tripmate_api.dart';

import '../data/health_repository.dart';

/// What the health screen shows.
sealed class HealthState {
  const HealthState();
}

final class HealthLoading extends HealthState {
  const HealthLoading();
}

final class HealthLoaded extends HealthState {
  const HealthLoaded(this.health);

  final Health health;
}

final class HealthFailed extends HealthState {
  const HealthFailed(this.error);

  final Object error;
}

/// Loads the answer of `GET /v1/health` once.
class HealthCubit extends Cubit<HealthState> {
  HealthCubit(this._repository) : super(const HealthLoading());

  final HealthRepository _repository;

  Future<void> load() async {
    emit(const HealthLoading());
    try {
      emit(HealthLoaded(await _repository.read()));
    } on Object catch (error) {
      emit(HealthFailed(error));
    }
  }
}
