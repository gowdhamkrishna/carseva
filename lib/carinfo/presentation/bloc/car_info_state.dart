import 'package:carseva/carinfo/domain/entities/car_entity.dart';

abstract class CarInfoState {}

class CarInfoInitialState extends CarInfoState {}

class CarInfoLoadingState extends CarInfoState {}

class CarInfoLoadedState extends CarInfoState {
  final UserCarEntity car;

  CarInfoLoadedState(this.car);
}

class CarInfoEmptyState extends CarInfoState {}

class CarInfoSavedState extends CarInfoState {
  final UserCarEntity car;

  CarInfoSavedState(this.car);
}

class CarInfoErrorState extends CarInfoState {
  final String message;

  CarInfoErrorState(this.message);
}
