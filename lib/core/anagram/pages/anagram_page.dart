import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/anagram/bloc/anagram_bloc.dart';

class AnagramPage extends StatelessWidget {
  final int level;

  const AnagramPage({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnagramBloc()..add(FetchAnagramData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Anagram Level $level',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              _buildCurrentWordGrid(context),
              const Spacer(),
              _buildLetterGrid(context),
              _buildControlButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWordGrid(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnagramLoaded) {
          final solutionLength = state.currentWord.isNotEmpty
              ? state.currentWord.length
              : state.anagram.length;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: solutionLength.clamp(1, 8), // Mantieni leggibile
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: solutionLength,
              itemBuilder: (context, index) {
                final letter = state.currentWord.length > index
                    ? state.currentWord[index]
                    : '';
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: letter.isEmpty ? Colors.grey[300] : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.black12, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    letter.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLetterGrid(BuildContext context) {
    return BlocBuilder<AnagramBloc, AnagramState>(
      builder: (context, state) {
        if (state is AnagramInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnagramLoaded) {
          final letters = state.anagram;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                final letter = letters[index];
                final isLetterUsed = state.usedLetters.contains(letter);

                return GestureDetector(
                  onTap: isLetterUsed
                      ? null // Non permette di selezionare la lettera se già usata
                      : () {
                          context.read<AnagramBloc>().add(AddLetterEvent(letter));
                        },
                  child: _buildLetterTile(letter, isLetterUsed),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLetterTile(String letter, bool isLetterUsed) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isLetterUsed ? Colors.grey : Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blueGrey, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<AnagramBloc>().add(RemoveLastLetterEvent());
          },
          child: const Text("Remove Last Letter"),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AnagramBloc>().add(ResetWordAnagramEvent());
          },
          child: const Text("Reset Word"),
        ),
      ],
    );
  }
}
