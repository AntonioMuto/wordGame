import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/controllers/playSounds_controller.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/home_page.dart';
import 'package:word_game/core/navigation/bloc/navigation_bloc.dart';
import 'package:word_game/core/navigation/pages/main_page.dart';
import 'package:word_game/core/sign_in/bloc/sign_in_bloc.dart';
import 'package:word_game/core/sign_in/pages/sign_in_page.dart';

import 'core/theme/bloc/theme_bloc.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['125EBE817C05F18F9575E85ECBC6C7B3']),
  );
  unawaited(MobileAds.instance.initialize());
  PlaysoundsController();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => NavigationBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.themeData,
            home: MainPage(), // Usa direttamente la tua pagina principale
          );
        },
      ),
    );
  }
}