import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dialog_event.dart';
part 'dialog_state.dart';

class DialogBloc extends Bloc<DialogEvent, DialogState> {
  DialogBloc() : super(DialogHidden()) {
    on<ShowDialogEvent>((event, emit) {
      if (state is DialogVisible) {
        emit(DialogHidden());
      }
      emit(DialogVisible(event.type));
    });
    
    on<DismissDialogEvent>((event, emit) => emit(DialogHidden()));
  }
}
