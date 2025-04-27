part of 'timer_bloc.dart';

abstract class TimerState {
  final int duration;
  const TimerState(this.duration);
}

class TimerInitial extends TimerState {
  const TimerInitial(int duration) : super(duration);
}

class TimerRunInProgress extends TimerState {
  const TimerRunInProgress(int duration) : super(duration);
}

class TimerRunComplete extends TimerState {
  const TimerRunComplete() : super(0);
}

class TimerStoppedState extends TimerState {
  const TimerStoppedState(int duration) : super(duration);
}
