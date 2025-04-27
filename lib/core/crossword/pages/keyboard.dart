import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Keyboard extends StatelessWidget {
  final bool onlyNumbers;
  final void Function(String letter) onKeyTap;

  final List<String> rowNumber0 = ['1', '2', '3'];
  final List<String> rowNumber1 = ['4', '5', '6'];
  final List<String> rowNumber2 = ['7', '8', '9'];
  final List<String> rowDelete = ['delete'];

  final List<String> row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  final List<String> row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  final List<String> row3 = ['clean', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'delete'];

  Keyboard({Key? key, required this.onKeyTap, required this.onlyNumbers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonWidth = constraints.maxWidth / 9.8;
        final double buttonHeight = buttonWidth * 1.2;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: onlyNumbers
                ? [
                    _buildRow(rowNumber0, buttonWidth, buttonHeight),
                    const SizedBox(height: 6),
                    _buildRow(rowNumber1, buttonWidth, buttonHeight),
                    const SizedBox(height: 6),
                    _buildRow(rowNumber2, buttonWidth, buttonHeight),
                    const SizedBox(height: 6),
                    _buildRow(rowDelete, buttonWidth, buttonHeight),
                  ]
                : [
                    _buildRow(row1, buttonWidth, buttonHeight),
                    const SizedBox(height: 8),
                    _buildRow(row2, buttonWidth, buttonHeight),
                    const SizedBox(height: 8),
                    _buildRow(row3, buttonWidth, buttonHeight),
                  ],
          ),
        );
      },
    );
  }

  Widget _buildRow(List<String> letters, double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: AnimatedKey(
            letter: letter,
            buttonWidth: letter == 'delete' || letter == 'clean' ? width * 1 : width * 0.9,
            buttonHeight: height,
            onKeyTap: onKeyTap,
          ),
        );
      }).toList(),
    );
  }
}

class AnimatedKey extends StatefulWidget {
  final String letter;
  final double buttonWidth;
  final double buttonHeight;
  final void Function(String letter) onKeyTap;

  const AnimatedKey({
    Key? key,
    required this.letter,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.onKeyTap,
  }) : super(key: key);

  @override
  State<AnimatedKey> createState() => _AnimatedKeyState();
}

class _AnimatedKeyState extends State<AnimatedKey> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
    widget.onKeyTap(widget.letter);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpecial = widget.letter == 'delete' || widget.letter == 'clean';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.buttonWidth,
              height: widget.buttonHeight,
              decoration: BoxDecoration(
                color: _isPressed
                    ? (isSpecial ? Colors.red.shade300 : Colors.grey.shade700)
                    : (isSpecial ? Colors.redAccent.shade200 : Colors.grey.shade800),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isPressed ? Theme.of(context).primaryColorDark.withOpacity(0.2) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isSpecial
                    ? Icon(
                        widget.letter == 'delete'
                            ? Icons.backspace_outlined
                            : Icons.cleaning_services_outlined,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        widget.letter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
