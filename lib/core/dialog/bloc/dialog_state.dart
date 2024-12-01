part of 'dialog_bloc.dart';

@immutable
sealed class DialogState {}

final class DialogInitial extends DialogState {}

final class DialogLoaded extends DialogState {}
final class DialogClose extends DialogState {}
