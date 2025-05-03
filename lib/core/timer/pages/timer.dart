import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/timer_bloc.dart';
import 'dart:math' as math;

class TimerCircle extends StatefulWidget {
  final int durationInMilliseconds;
  final void Function() onTimerComplete;

  const TimerCircle({
    super.key,
    required this.durationInMilliseconds,
    required this.onTimerComplete,
  });

  @override
  State<TimerCircle> createState() => _TimerCircleState();
}

class _TimerCircleState extends State<TimerCircle> {
  @override
  void initState() {
    super.initState();
    context.read<TimerBloc>().add(TimerStarted(widget.durationInMilliseconds));
  }

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
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, current) => current.duration != prev.duration,
      builder: (context, state) {
        if (state is TimerRunComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onTimerComplete();
          });
        }

        final remainingDuration = Duration(milliseconds: state.duration);
        final progress = state is TimerRunInProgress
            ? remainingDuration.inMilliseconds / widget.durationInMilliseconds
            : 0.0;

        Color progressColor;
        if (remainingDuration.inSeconds >= 30) {
          progressColor = Colors.blueAccent;
        } else if (remainingDuration.inSeconds > 10) {
          progressColor = Colors.orange;
        } else {
          progressColor = Colors.red;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi), // Importa dart:math
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.shade300,
                  color: progressColor,
                ),
              ),
            ),
            Text(
              _formatTime(remainingDuration),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
