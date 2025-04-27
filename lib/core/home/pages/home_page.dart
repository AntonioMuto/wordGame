import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/game_section_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _sections = [
      _buildGameSections(context),
    ];

    return Column(
      children: [
        Expanded(child: _sections[_selectedIndex]),  // Solo la sezione di gioco
      ],
    );
  }

  Widget _buildGameSections(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial) {
          return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark,));
        } else if (state is HomeLoaded) {
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.sections.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 40.0,
                    child: FadeInAnimation(
                      child: GameSectionCard(section: state.sections[index]),
                    ),
                  ),
                );
              },
            ),
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
