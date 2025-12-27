import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    
    on<ToggleEvent>((event, emit) {
      final bool isDark = !state.isDark;
      emit(ThemeChangedState(isDark));
    });

    on<SystemTheme>((event, emit) {
      emit(ThemeChangedState(event.isDark));
    });
  }
}
