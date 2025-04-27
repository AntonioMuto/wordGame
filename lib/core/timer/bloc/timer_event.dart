part of 'timer_bloc.dart';

abstract class TimerEvent {
  const TimerEvent();
}

class TimerStarted extends TimerEvent {
  final int duration;
  const TimerStarted(this.duration);
}

class TimerStopped extends TimerEvent {
  const TimerStopped();
}

class TimerReset extends TimerEvent {
  const TimerReset();
}

class TimerTicked extends TimerEvent {
  const TimerTicked();
}

class TimerAdd extends TimerEvent {
  final int seconds;
  const TimerAdd(this.seconds);
}

class TimerSubtract extends TimerEvent {
  final int seconds;
  const TimerSubtract(this.seconds);
}
