import 'package:flutter/material.dart';

class TimerCircle extends StatefulWidget {
  final Duration duration; 

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
      duration: widget.duration, 
    )..forward(); 
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
    int centiseconds = (duration.inMilliseconds % 1000) ~/ 10; 

    
    if (duration.inMilliseconds < 1000) {
      return "00:${centiseconds.toString().padLeft(2, '0')}";
    }

    
    if (minutes > 0) {
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }

    
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
        final timeString = _formatTime(remainingDuration); 

        
        Color progressColor;
        Color textColor;

        
        if (remainingDuration.inSeconds >= widget.duration.inSeconds * 0.5) {
          progressColor = Colors.blueAccent; 
        } else if (remainingDuration.inSeconds > 10) {
          progressColor = Colors.orange; 
        } else {
          progressColor = Colors.red; 
        }

        
        if (remainingDuration.inSeconds >= widget.duration.inSeconds * 0.5) {
          textColor = Colors.white; 
        } else if (remainingDuration.inSeconds > 10) {
          textColor = Colors.orange; 
        } else {
          textColor = Colors.red; 
        }

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
                color: progressColor, 
              ),
            ),
            Text(
              timeString, 
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
