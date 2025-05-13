import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/navigation/pages/main_page.dart';
import 'package:word_game/core/sign_in/bloc/sign_in_bloc.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background.withOpacity(0.1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: BlocConsumer<SignInBloc, SignInState>(
              listener: (context, state) {
                if (state is SignInSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainPage()),
                  );
                }
              },
              builder: (context, state) {
                // Gestione errori specifici
                final isFailure = state is SignInFailure;
                final wrongPassword =
                    isFailure ? state.wrongPassword ?? false : false;
                final userNotFound =
                    isFailure ? state.userNotFound ?? false : false;
                final errorMessage =
                    isFailure ? state.errorMessage : null;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gamepad_rounded,
                        size: 72, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      "Benvenuto in WordGame",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(
                      controller: usernameController,
                      label: "Username",
                      icon: Icons.person,
                      theme: theme,
                      showError: userNotFound,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      theme: theme,
                      obscure: true,
                      showError: wrongPassword,
                    ),
                    const SizedBox(height: 24),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: state is SignInLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 30, 121, 195),
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () {
                                  context.read<SignInBloc>().add(
                                        SignInSubmitted(
                                          usernameController.text,
                                          passwordController.text,
                                        ),
                                      );
                                },
                                child: Text(
                                  "Accedi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    bool obscure = false,
    bool showError = false,
    bool showCheck = false,
  }) {
    Icon? suffix;
    if (showError) {
      suffix = const Icon(Icons.close, color: Colors.red);
    } else if (showCheck) {
      suffix = const Icon(Icons.check, color: Colors.green);
    }

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        suffixIcon: suffix,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 45, 148, 232)),
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onBackground.withOpacity(0.7),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
