import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_trip_planner/core/colors.dart';
import 'package:smart_trip_planner/screens/home_page.dart';
import 'package:smart_trip_planner/screens/sign_in_screen.dart';
import 'screens/itinerary_screen.dart';
import 'models/itinerary.dart';
import 'services/json_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/login': (context) => const SignInPage()},
      debugShowCheckedModeBanner: false,
      title: 'Smart Trip Planner',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        appBarTheme: AppBarTheme(
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 75,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          elevation: 0,
        ),
        // Elevated Button Global Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            backgroundColor: AppColors.primary, // button background
            foregroundColor: Colors.white, // text color
            minimumSize: const Size(
              double.infinity,
              52,
            ), // full width, 48px tall
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // rounded corners
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary, // Default background
          contentTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          behavior: SnackBarBehavior.floating, // Makes all SnackBars floating
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(120),
          ),
          elevation: 16,
        ),
      ),
      // home: HomePage(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is logged in → go to HomePage
            return const HomePage();
          }
          // User not logged in → go to SignInPage
          return const SignInPage();
        },
      ),
    );
  }
}
