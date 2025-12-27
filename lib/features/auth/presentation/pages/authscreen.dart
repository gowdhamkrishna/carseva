import 'package:carseva/features/HomePage/presentation/pages/HomePage.dart';
import 'package:carseva/features/auth/presentation/pages/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_event.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_state.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthBlocState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Loading...")));
        }

        if (state is AuthSuccessState) {
          Navigator.pushReplacement(
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
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 100,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 40),

                  /// Google Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.g_mobiledata_rounded,
                        color: Colors.red,
                        size: 32,
                      ),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(GoogleLoginEvent());
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// Phone OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text(
                        "Continue with Phone OTP",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        // TODO: navigate phone otp page
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// Email Button → navigates to EmailLoginScreen
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        "Sign in with Email",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreenPassword(),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    "By continuing, you agree to Terms & Privacy",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
