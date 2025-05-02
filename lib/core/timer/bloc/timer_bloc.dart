import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  static const int _tickDuration = 10; // 10 ms
  Timer? _timer;

  TimerBloc() : super(const TimerInitial(0)) {
    on<TimerStarted>(_onStarted);
    on<TimerStopped>(_onStopped);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerAdd>(_onAdd);
    on<TimerRestart>(_onNewRestart);
    on<TimerSubtract>(_onSubtract);
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(TimerRunInProgress(event.duration));
    _timer = Timer.periodic(const Duration(milliseconds: _tickDuration), (timer) {
      add(const TimerTicked());
    });
  }

  void _onStopped(TimerStopped event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(TimerStoppedState(state.duration));
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(const TimerInitial(0));
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    final newDuration = state.duration - _tickDuration;
    if (newDuration <= 0) {
      _timer?.cancel();
      emit(const TimerRunComplete());
    } else {
      emit(TimerRunInProgress(newDuration));
    }
  }

  void _onAdd(TimerAdd event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(state.duration + event.milliseconds));
  }

  void _onNewRestart(TimerRestart event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: _tickDuration), (timer) {
      add(const TimerTicked());
    });
    emit(TimerRunInProgress(state.duration + event.milliseconds));
  }

  void _onSubtract(TimerSubtract event, Emitter<TimerState> emit) {
    final updatedDuration = (state.duration - event.milliseconds).clamp(0, double.infinity).toInt();
    if (updatedDuration == 0) {
      _timer?.cancel();
      emit(const TimerRunComplete());
    } else {
      emit(TimerRunInProgress(updatedDuration));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
