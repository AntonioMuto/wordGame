import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:word_game/services/api_handler.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<SignInSubmitted>((event, emit) async {
      emit(SignInLoading());

      final result = await ApiHandler.post('/auth/login', body: {
        'username': event.username,
        'password': event.password,
      });
      if (result.success) {
        final userData = result.data;
        // fai qualcosa, es: salva token, naviga, ecc.
        emit(SignInSuccess(
            username: userData['username'],
            token: userData['accessToken'],
            coins: userData['coins']));
      } else {
        emit(SignInFailure(
            errorMessage: result.errorMessage ?? 'Errore sconosciuto',
            userNotFound: result.data['userNotFound'] ?? false,
            wrongPassword: result.data['wrongPassword'] ?? false));
      }
    });
  }
}
