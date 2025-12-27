import 'package:carseva/carinfo/domain/entities/car_entity.dart';

abstract class CarInfoEvent {}

class LoadCarInfoEvent extends CarInfoEvent {
  final String userId;

  LoadCarInfoEvent(this.userId);
}

class SaveCarInfoEvent extends CarInfoEvent {
  final String userId;
  final UserCarEntity car;

  SaveCarInfoEvent({
    required this.userId,
    required this.car,
  });
}

class ClearCarInfoEvent extends CarInfoEvent {}
