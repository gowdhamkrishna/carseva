part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

class ToggleEvent extends ThemeEvent {}

class SystemTheme extends ThemeEvent {
  final bool isDark;
  SystemTheme(this.isDark);
}
