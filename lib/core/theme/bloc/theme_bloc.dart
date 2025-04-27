import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/theme/bloc/theme_state.dart';

part 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.darkTheme) {
    on<ThemeEvent>((event, emit) {
      if (event == ThemeEvent.toggleDark) {
        emit(ThemeState.darkTheme);
      } else if (event == ThemeEvent.toggleLight) {
        emit(ThemeState.lightTheme);
      }
    });
  }
}
