import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_trip_planner/screens/sign_in_screen.dart';
import '../services/auth_service.dart';
// import 'sign_in_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Your Account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text("Name: ${user.displayName ?? 'N/A'}"),
              Text("Email: ${user.email ?? 'N/A'}"),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await authService.signOut();
                // after sign out → go back to login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
