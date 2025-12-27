part of 'theme_bloc.dart';

@immutable
abstract class ThemeState {
  final isDark;
  const ThemeState(this.isDark);
}

final class ThemeInitial extends ThemeState {
  ThemeInitial() : super(true);
}

class ThemeChangedState extends ThemeState {
  const ThemeChangedState(bool isDark) : super(isDark);
}
