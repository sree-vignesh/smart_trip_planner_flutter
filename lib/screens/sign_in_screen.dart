import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _signInWithEmail() async {
    final user = await _authService.signInWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    // if (user != null) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const HomePage()),
    //   );
    // }
  }

  Future<void> _signInWithGoogle() async {
    await _authService.initializeGoogleSignIn(
      serverClientId:
          '561584619861-6pvdk7t5pu3evrhb80smdc98fp8cfath.apps.googleusercontent.com',
    ); // returns User?
    // final user = await _authService.initializeGoogleSignIn();
    final user = await _authService.attemptInitialSignIn(); // returns User?
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signInWithEmail,
              child: const Text("Sign In with Email"),
            ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: const Text("Sign In with Google"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              ),
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
