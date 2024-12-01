part of 'dialog_bloc.dart';

@immutable
sealed class DialogEvent {}


class ShowDialogEvent extends DialogEvent {}
class CloseDialogEvent extends DialogEvent {}
