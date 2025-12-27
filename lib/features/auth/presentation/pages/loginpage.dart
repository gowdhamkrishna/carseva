import 'package:carseva/features/HomePage/presentation/pages/HomePage.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_event.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_state.dart';
import 'package:carseva/features/auth/presentation/pages/register_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreenPassword extends StatefulWidget {
  const LoginScreenPassword({super.key});

  @override
  State<LoginScreenPassword> createState() => _LoginScreenPasswordState();
}

class _LoginScreenPasswordState extends State<LoginScreenPassword> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  ///--------------- EMAIL VALIDATION ----------------///
  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<AuthBloc, AuthBlocState>(
        listener: (context, state) {
          if (state is AuthLoadingState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Logging in...")));
          }

          if (state is AuthSuccessState) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CarSevaHome()),
            );
          }

          if (state is AuthFailureState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = _email.text.trim();
                      final password = _password.text.trim();

                      /// ---------- VALIDATIONS -----------///

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Email & Password cannot be empty"),
                          ),
                        );
                        return;
                      }

                      if (!_isValidEmail(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid Email format")),
                        );
                        return;
                      }

                      if (password.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Password must be at least 6 characters long",
                            ),
                          ),
                        );
                        return;
                      }

                      /// If validation passes -> call bloc
                      context.read<AuthBloc>().add(
                        LoginEvent(email: email, password: password),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
