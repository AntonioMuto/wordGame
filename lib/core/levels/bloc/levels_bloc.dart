import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'levels_event.dart';
part 'levels_state.dart';

class LevelsBloc extends Bloc<LevelsEvent, LevelsState> {
  LevelsBloc() : super(LevelsInitial()) {
    on<LevelsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
