import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/home_page.dart';
import 'package:word_game/core/navigation/bloc/navigation_bloc.dart';
import 'package:word_game/core/navigation/pages/main_page.dart';
import 'package:word_game/core/sign_in/bloc/sign_in_bloc.dart';
import 'package:word_game/core/sign_in/pages/sign_in_page.dart';

import 'core/theme/bloc/theme_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.themeData, // Usa il tema dal ThemeBloc
            // home: BlocProvider(create: (context) => SignInBloc(), child: SignInPage()),
            home: BlocProvider(create: (context) => NavigationBloc(), child: MainPage()),
          );
        },
      ),
    );
  }
}