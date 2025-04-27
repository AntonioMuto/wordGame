import 'package:flutter/material.dart';
import 'appColors.dart'; // importa la tua classe di colori

class ThemeState {
  final ThemeData themeData;

  ThemeState(this.themeData);

  static ThemeState get darkTheme => ThemeState(
        ThemeData.dark().copyWith(
          primaryColor: AppColors.darkBackground,
          primaryColorDark: AppColors.darkSecondaryColor,
          scaffoldBackgroundColor: AppColors.darkBackground,
          canvasColor: AppColors.darkBottomAppBar,
          cardColor: AppColors.darkCard,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.darkAppBarBackground,
            foregroundColor: AppColors.darkAppBarForeground,
            shape: Border(
              bottom: BorderSide(color: AppColors.darkAppBarBorder),
            ),
          ),
        ),
      );

  static ThemeState get lightTheme => ThemeState(
        ThemeData.light().copyWith(
          primaryColor: AppColors.lightBackground,
          primaryColorDark: AppColors.lightSecondaryColor,
          scaffoldBackgroundColor: AppColors.lightBackground,
          canvasColor: AppColors.lightBottomAppBar,
          cardColor: AppColors.lightCard,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.lightAppBarBackground,
            foregroundColor: AppColors.lightAppBarForeground,
            shape: Border(
              bottom: BorderSide(color: AppColors.lightAppBarBorder),
            ),
          ),
        ),
      );
}
