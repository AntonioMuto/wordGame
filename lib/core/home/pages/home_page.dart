import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/game_section_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial) {
          return const Center(child: CircularProgressIndicator()); // Loading
        } else if (state is HomeLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.sections.length,
            itemBuilder: (context, index) {
              return GameSectionCard(section: state.sections[index]);
            },
          );
        } else if (state is HomeError) {
          return const Center(child: Text("Errore di caricamento"));
        } else {
          return const Center(child: Text("Stato sconosciuto"));
        }
      },
    );
  }
}
