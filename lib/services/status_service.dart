import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StatusService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static String get myUid => FirebaseAuth.instance.currentUser?.uid ?? 'anon';

  static String get myName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.phoneNumber ??
      'Usuario';

  static Stream<QuerySnapshot> statusesStream() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _db
        .collection('statuses')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .snapshots();
  }

  static Stream<QuerySnapshot> userStatusesStream(String uid) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _db
        .collection('statuses')
        .where('uid', isEqualTo: uid)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('expiresAt', descending: false)
        .snapshots();
  }

  static Future<void> publishTextStatus({
    required String text,
    required int backgroundColor,
  }) async {
    final now = DateTime.now();
    await _db.collection('statuses').add({
      'uid': myUid,
      'name': myName,
      'type': 'text',
      'content': text,
      'backgroundColor': backgroundColor,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'viewers': [],
    });
  }

  static Future<void> publishImageStatus({
    required File imageFile,
    String caption = '',
  }) async {
    final now = DateTime.now();
    final ref = _storage
        .ref()
        .child('statuses/$myUid/${now.millisecondsSinceEpoch}.jpg');

    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await _db.collection('statuses').add({
      'uid': myUid,
      'name': myName,
      'type': 'image',
      'content': url,
      'caption': caption,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'viewers': [],
    });
  }

  static Future<void> markSeen(String statusId) async {
    await _db.collection('statuses').doc(statusId).update({
      'viewers': FieldValue.arrayUnion([myUid]),
    });
  }

  static Map<String, List<QueryDocumentSnapshot>> groupByUser(
      List<QueryDocumentSnapshot> docs) {
    final map = <String, List<QueryDocumentSnapshot>>{};
    for (final doc in docs) {
      final uid = doc['uid'] as String;
      map.putIfAbsent(uid, () => []).add(doc);
    }
    return map;
  }
}
