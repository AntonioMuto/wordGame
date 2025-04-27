import 'package:flutter/material.dart';

class TimerCircle extends StatefulWidget {
  final Duration duration; // Durata passata al widget

  const TimerCircle({Key? key, required this.duration}) : super(key: key);

  @override
  _TimerCircleState createState() => _TimerCircleState();
}

class _TimerCircleState extends State<TimerCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration, // Durata passata dal widget
    )..forward(); // Avvia il timer immediatamente
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;
  int seconds = duration.inSeconds % 60;
  int centiseconds = (duration.inMilliseconds % 1000) ~/ 10; // Centesimi di secondo

  // Se il tempo è inferiore a 1 secondo, mostra "00:centesimi"
  if (duration.inMilliseconds < 1000) {
    return "00:${centiseconds.toString().padLeft(2, '0')}";
  }

  // Se la durata è maggiore di 1 minuto, mostra mm:ss
  if (minutes > 0) {
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Se siamo sotto il minuto, mostra ss:ss (secondi e centesimi)
  else {
    return "${seconds.toString().padLeft(2, '0')}:${centiseconds.toString().padLeft(2, '0')}";
  }
}


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remainingDuration = widget.duration * (1 - _controller.value);
        final timeString = _formatTime(remainingDuration); // Tempo formattato

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: _controller.value,
                strokeWidth: 5,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              timeString, // Mostriamo il tempo formattato
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
