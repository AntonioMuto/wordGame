import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/home/pages/home_page.dart';
import 'package:word_game/core/sign_in/bloc/sign_in_bloc.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            BlocBuilder<SignInBloc, SignInState>(
              builder: (context, state) {
                return Column(
              children: [
                // Messaggio di errore, visibile solo se c'è un errore
                if (state is SignInFailure)
                  Text(
                    state.errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 10), // Spaziatura tra il messaggio e il pulsante

                // Mostra il pulsante o il caricamento
                if (state is SignInLoading)
                  CircularProgressIndicator( color: Colors.white,)
                else
                  ElevatedButton(
                    onPressed: () {
                      final username = usernameController.text;
                      final password = passwordController.text;
                      context
                          .read<SignInBloc>()
                          .add(SignInSubmitted(username, password));
                    },
                    child: Text("Login", style: TextStyle(color: Colors.white)),
                  ),
              ],
            );
              },
            ),
            BlocListener<SignInBloc, SignInState>(
              listener: (context, state) {
                if (state is SignInSuccess) {
                  // Naviga alla HomePage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              },
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}