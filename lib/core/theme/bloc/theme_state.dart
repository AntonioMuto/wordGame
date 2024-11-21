part of 'theme_bloc.dart';

class ThemeState {
  final ThemeData themeData;

  ThemeState(this.themeData);

  static ThemeState get darkTheme =>
      ThemeState(ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color.fromARGB(255, 36, 36, 36),
        
      ));

  static ThemeState get lightTheme =>
      ThemeState(ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
      ));
}