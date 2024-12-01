part of 'theme_bloc.dart';

class ThemeState {
  final ThemeData themeData;

  ThemeState(this.themeData);

  static ThemeState get darkTheme =>
      ThemeState(ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 47, 47, 47),
          foregroundColor: Colors.white,
          shape: Border(bottom: BorderSide(color: Color.fromARGB(255, 87, 87, 87))),
        ),
        cardColor: const Color.fromARGB(255, 36, 36, 36),
        
      ));

  static ThemeState get lightTheme =>
      ThemeState(ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 47, 47, 47),
          foregroundColor: Colors.white,
          shape: Border(bottom: BorderSide(color: Color.fromARGB(255, 87, 87, 87))),
        ),
        cardColor: Colors.white,
      ));
}