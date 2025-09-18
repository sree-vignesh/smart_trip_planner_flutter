import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_trip_planner/core/colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (user != null) ...[
                // Profile card
                SizedBox(
                  height: 150,
                  width: 300,
                  child: Card(
                    // clipBehavior: ,
                    color: AppColors.cardBackground,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: user.photoURL == null
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 40,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 20, thickness: 1),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName ?? "Guest",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.email ?? "N/A",

                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Logout button OUTSIDE the card
                ElevatedButton(
                  // style:ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(AppColors.cardBackground),
                  //   maximumSize: MaterialStateProperty.all(Size(30, 30)),
                  //   ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Navigate back to login page
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    // backgroundColor: AppColors.cardBackground,
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.redAccent,
                    // foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    // maximumSize: Size(10, 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,

                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                  child: const Text("Logout", style: TextStyle(fontSize: 16)),
                ),
              ] else
                const Text("No user signed in"),
            ],
          ),
        ),
      ),
    );
  }
}
