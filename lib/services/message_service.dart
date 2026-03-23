import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String conversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static String? get myUid => FirebaseAuth.instance.currentUser?.uid;

  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(
    String conversationId,
  ) {

    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  static Future<void> _ensureConversation({
    required String conversationId,
    required String senderUid,
    required String receiverUid,
    required String lastMessage,
  }) async {
    await _db.collection('conversations').doc(conversationId).set({
      'lastMessage': lastMessage,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participants': [senderUid, receiverUid],
    }, SetOptions(merge: true));
  }

  static Future<void> sendText({
    required String conversationId,
    required String text,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      await _ensureConversation(
        conversationId: conversationId,
        senderUid: senderUid,
        receiverUid: receiverUid,
        lastMessage: cleanText,
      );

      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'type': 'text',
        'content': cleanText,
        'senderUid': senderUid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendImage({
    required String conversationId,
    required String imagePath,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
      await _ensureConversation(
        conversationId: conversationId,
        senderUid: senderUid,
        receiverUid: receiverUid,
        lastMessage: '📷 Foto',
      );

      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'type': 'image',
        'content': imagePath,
        'senderUid': senderUid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendAudio({
    required String conversationId,
    required String audioPath,
    required String durationLabel,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
      await _ensureConversation(
        conversationId: conversationId,
        senderUid: senderUid,
        receiverUid: receiverUid,
        lastMessage: '🎤 Audio',
      );

      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'type': 'audio',
        'content': audioPath,
        'durationLabel': durationLabel,
        'senderUid': senderUid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendAttachment({
    required String conversationId,
    required String content,
    required String type,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
      final preview =
          content.length > 40 ? '${content.substring(0, 40)}...' : content;

      await _ensureConversation(
        conversationId: conversationId,
        senderUid: senderUid,
        receiverUid: receiverUid,
        lastMessage: preview,
      );

      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'type': type,
        'content': content,
        'senderUid': senderUid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      rethrow;
    }
  }
}
