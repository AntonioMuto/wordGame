import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/timer_bloc.dart';

class TimerCircle extends StatelessWidget {
  final int durationInMilliseconds;
  final void Function() onTimerComplete;

  const TimerCircle({super.key, required this.durationInMilliseconds, required this.onTimerComplete});

  String _formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    int centiseconds = (duration.inMilliseconds % 1000) ~/ 10;

    if (duration.inMilliseconds < 1000) {
      return "00:${centiseconds.toString().padLeft(2, '0')}";
    } else if (minutes > 0) {
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${seconds.toString().padLeft(2, '0')}:${centiseconds.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<TimerBloc>().add(TimerStarted(durationInMilliseconds));

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        if (state is TimerRunComplete) {
          onTimerComplete();
        }
        final remainingDuration = Duration(milliseconds: state.duration);

        final progress = state is TimerRunInProgress
            ? remainingDuration.inMilliseconds / durationInMilliseconds
            : 0.0;

        Color progressColor;
        Color textColor;

        // Imposta il colore del progresso
        if (remainingDuration.inSeconds >= 30) {
          progressColor = Colors.blueAccent;
          textColor = Colors.white;
        } else if (remainingDuration.inSeconds > 10) {
          progressColor = Colors.orange;
          textColor = Colors.orange;
        } else {
          progressColor = Colors.red;
          textColor = Colors.red;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                width: 120,
                height: 120,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(
                      3.14159), // oppure Matrix4.diagonal3Values(-1, 1, 1)
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey.shade300,
                    color: progressColor,
                  ),
                )),
            Text(
              _formatTime(remainingDuration),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
