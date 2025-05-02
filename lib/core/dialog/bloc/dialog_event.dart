part of 'dialog_bloc.dart';

enum DialogType { completion, timeout, exitConfirmation }

@immutable
sealed class DialogEvent {}
class ShowDialogEvent extends DialogEvent {
  final DialogType type;
  ShowDialogEvent(this.type);
}
class DismissDialogEvent extends DialogEvent {}