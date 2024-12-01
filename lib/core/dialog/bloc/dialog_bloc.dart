import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dialog_event.dart';
part 'dialog_state.dart';

class DialogBloc extends Bloc<DialogEvent, DialogState> {
  DialogBloc() : super(DialogInitial()) {
    on<ShowDialogEvent>(_showDialog);
  }

  _showDialog(ShowDialogEvent event, Emitter<DialogState> emit) {
    emit(DialogLoaded());
    
  }
}
