part of 'timer_bloc.dart';

abstract class TimerEvent {
  const TimerEvent();
}

class TimerStarted extends TimerEvent {
  final int duration; // Ora in millisecondi
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
  final int milliseconds; // Rinominato da "seconds" a "milliseconds"
  const TimerAdd(this.milliseconds);
}

class TimerRestart extends TimerEvent {
  final int milliseconds;
  const TimerRestart(this.milliseconds);
}

class TimerSubtract extends TimerEvent {
  final int milliseconds; // Rinominato da "seconds" a "milliseconds"
  const TimerSubtract(this.milliseconds);
}
