import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/sign_in/bloc/sign_in_bloc.dart';
import 'package:word_game/sign_in/pages/sign_in_page.dart';

import 'theme/bloc/theme_bloc.dart';

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
            home: BlocProvider(create: (context) => SignInBloc(), child: SignInPage()),
          );
        },
      ),
    );
  }
}