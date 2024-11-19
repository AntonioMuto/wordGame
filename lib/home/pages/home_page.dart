import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/sign_in/bloc/sign_in_bloc.dart';
import 'package:word_game/sign_in/pages/sign_in_page.dart';
import 'package:word_game/theme/bloc/theme_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => SignInBloc(),
                    child: SignInPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Switch between Dark and Light Themes:'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<ThemeBloc>().add(ThemeEvent.toggleDark),
                  child: const Text('Dark'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => context.read<ThemeBloc>().add(ThemeEvent.toggleLight),
                  child: const Text('Light'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}