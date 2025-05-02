part of 'dialog_bloc.dart';

abstract class DialogState {}
class DialogVisible extends DialogState {
  final DialogType type;
  DialogVisible(this.type);
}
class DialogHidden extends DialogState {}