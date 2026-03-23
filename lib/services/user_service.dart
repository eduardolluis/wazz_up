import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> saveCurrentUser({
    String? name,
    String? email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name ?? user.displayName ?? 'Usuario',
      'email': email ?? user.email ?? '',
      'status': 'Hey there! I am using Whatzapp',
      'isOnline': true,
    }, SetOptions(merge: true));
  }
}