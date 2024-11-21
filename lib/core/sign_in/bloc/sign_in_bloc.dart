import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<SignInSubmitted>((event, emit) async {
      emit(SignInLoading());

      // Simulazione di chiamata API per autenticazione
      await Future.delayed(Duration(seconds: 2)); // Simula il tempo di risposta

      if (event.username == "admin" && event.password == "password") {
        emit(SignInSuccess());
      } else {
        emit(SignInFailure("Credenziali non valide"));
      }
    });
  }
}
