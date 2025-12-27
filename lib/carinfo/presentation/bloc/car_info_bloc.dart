import 'package:carseva/carinfo/domain/usecases/get_current_car.dart';
import 'package:carseva/carinfo/domain/usecases/save_current.dart';
import 'package:carseva/carinfo/presentation/bloc/car_info_event.dart';
import 'package:carseva/carinfo/presentation/bloc/car_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarInfoBloc extends Bloc<CarInfoEvent, CarInfoState> {
  final GetCurrentCar getCurrentCar;
  final SaveCurrentCar saveCurrentCar;

  CarInfoBloc({
    required this.getCurrentCar,
    required this.saveCurrentCar,
  }) : super(CarInfoInitialState()) {
    on<LoadCarInfoEvent>((event, emit) async {
      emit(CarInfoLoadingState());
      try {
        final car = await getCurrentCar(event.userId);
        if (car != null) {
          emit(CarInfoLoadedState(car));
        } else {
          emit(CarInfoEmptyState());
        }
      } catch (e) {
        emit(CarInfoErrorState(e.toString()));
      }
    });

    on<SaveCarInfoEvent>((event, emit) async {
      emit(CarInfoLoadingState());
      try {
        await saveCurrentCar(
          userId: event.userId,
          car: event.car,
        );
        emit(CarInfoSavedState(event.car));
      } catch (e) {
        emit(CarInfoErrorState(e.toString()));
      }
    });

    on<ClearCarInfoEvent>((event, emit) {
      emit(CarInfoInitialState());
    });
  }
}
