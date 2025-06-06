// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc_files/auth_bloc/login_bloc.dart';
import '../utils/curved_cliper.dart';
import '../widgets/login_form.dart';
import 'dashboard_screen.dart'; // Your dashboard

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacementNamed("/dashboard");
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.deepPurple,
                  alignment: Alignment.center,
                  child: const Text(
                    'Mini CRM',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: LoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
