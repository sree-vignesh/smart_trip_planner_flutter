import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logUserSearch(String query) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (user != null) {
      // Build a unique ID using name, email, and uid
      final safeName = user.displayName?.replaceAll(' ', '_') ?? "Guest";
      final safeEmail =
          user.email?.replaceAll(RegExp(r'[^\w@.-]'), '_') ?? "noemail";
      final docId = "${safeName}_${safeEmail}_${user.uid}";

      await _firestore
          .collection('user_searches')
          .doc(docId)
          .collection('search_history')
          .add({'query': query, 'timestamp': FieldValue.serverTimestamp()});
    }
  }
}
