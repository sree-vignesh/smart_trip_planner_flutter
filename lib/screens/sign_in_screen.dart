import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_trip_planner/core/colors.dart';
import 'package:smart_trip_planner/models/itinerary.dart';
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
    );
    final user = await _authService.signInWithGoogle();
    // if(user !)
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      // Do NOT manually navigate to HomePage
      // StreamBuilder in main.dart will detect the change
      print("Signed in as: ${user.displayName}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text("Sign In"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                " Itinera AI",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Hi, Welcome Back",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              Text(
                "Login to your account",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  wordSpacing: 0,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  fixedSize: const Size(10, 10),
                  // fontFamily:GoogleFonts.getFont("inter"),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FaIcon(FontAwesomeIcons.google, color: Colors.lightBlue),
                    Image.asset("assets/google-logo.png", height: 20),
                    const SizedBox(width: 10),
                    const Text("Sign In with Google"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const SizedBox(width: 8),
                  Text(
                    "Or Sign in with Email",
                    style: GoogleFonts.inter(color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 48),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Email",
                  labelStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey.shade400,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Password",
                  labelStyle: GoogleFonts.inter(color: Colors.grey.shade400),

                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                  ),
                  suffixIcon: Icon(
                    Icons.visibility_off,
                    color: Colors.grey.shade400,
                  ), // you can toggle this for show/hide
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signInWithEmail,
                child: const Text("Login"),
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                ),
                child: Text(
                  "Create Account",
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
