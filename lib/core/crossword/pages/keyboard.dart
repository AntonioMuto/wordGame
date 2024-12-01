import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/crossword_bloc.dart';

class Keyboard extends StatelessWidget {
  final List<String> row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  final List<String> row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  final List<String> row3 = [
    'clean',
    'Z',
    'X',
    'C',
    'V',
    'B',
    'N',
    'M',
    'delete'
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = screenWidth / 10 - 8;
    const double spacing = 7.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(10)
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKeyboardRow(context, row1, buttonSize +2, spacing - 1),
          const SizedBox(height: 12),
          _buildKeyboardRow(context, row2, buttonSize + 4, spacing),
          const SizedBox(height: 12),
          _buildKeyboardRow(context, row3, buttonSize + 1, spacing-1,
              isLastRow: true),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(
    BuildContext context,
    List<String> letters,
    double buttonSize,
    double spacing, {
    bool isLastRow = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: AnimatedKey(
            letter: letter,
            buttonSize: buttonSize,
          ),
        );
      }).toList(),
    );
  }
}

class AnimatedKey extends StatefulWidget {
  final String letter;
  final double buttonSize;

  const AnimatedKey({
    Key? key,
    required this.letter,
    required this.buttonSize,
  }) : super(key: key);

  @override
  _AnimatedKeyState createState() => _AnimatedKeyState();
}

class _AnimatedKeyState extends State<AnimatedKey>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _onTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });

    if (widget.letter == 'delete') {
      context.read<CrosswordBloc>().add(RemoveLetterEvent());
    } else if (widget.letter == 'clean') {
      context.read<CrosswordBloc>().add(ResetWordEvent());
    } else {
      context
          .read<CrosswordBloc>()
          .add(InsertLetterEvent(letter: widget.letter));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.letter == 'delete' ||
                            widget.letter == 'clean'
                        ? [Colors.red.shade600, Colors.red.shade400]
                        : [Colors.blueGrey.shade800, Colors.blueGrey.shade600],
                    begin: Alignment
                        .topLeft, // Corretta posizione di partenza del gradiente
                    end: Alignment
                        .bottomRight, // Corretta posizione finale del gradiente
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                width: widget.letter == 'delete' || widget.letter == 'clean'
                    ? widget.buttonSize * 1.5
                    : widget.buttonSize,
                height: widget.buttonSize + 12,
                child: Center(
                  child: widget.letter == 'delete'
                      ? const Icon(
                          Icons.backspace,
                          color: Colors.white,
                          size: 24,
                        )
                      : widget.letter == 'clean'
                          ? const Icon(
                              Icons.cleaning_services,
                              color: Colors.white,
                              size: 24,
                            )
                          : Text(
                              widget.letter,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                ),
              ));
        },
      ),
    );
  }
}
