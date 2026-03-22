import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MessageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ID de conversación estable entre dos usuarios
  static String conversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// UID del usuario autenticado
  static String? get myUid => FirebaseAuth.instance.currentUser?.uid;

  /// Stream de mensajes en tiempo real
  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(
    String conversationId,
  ) {
    debugPrint('📡 Escuchando conversación: $conversationId');

    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Enviar mensaje de texto
  static Future<void> sendText({
    required String conversationId,
    required String text,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'type': 'text',
        'content': text.trim(),
        'senderUid': senderUid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _db.collection('conversations').doc(conversationId).set({
        'lastMessage': text.trim(),
        'lastTimestamp': FieldValue.serverTimestamp(),
        'participants': [senderUid, receiverUid],
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error enviando texto: $e');
      rethrow;
    }
  }

  /// Enviar mensaje de imagen
  static Future<void> sendImage({
    required String conversationId,
    required String imagePath,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
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

      await _db.collection('conversations').doc(conversationId).set({
        'lastMessage': '📷 Foto',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'participants': [senderUid, receiverUid],
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error enviando imagen: $e');
      rethrow;
    }
  }

  /// Enviar mensaje de audio
  static Future<void> sendAudio({
    required String conversationId,
    required String audioPath,
    required String durationLabel,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
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

      await _db.collection('conversations').doc(conversationId).set({
        'lastMessage': '🎤 Audio',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'participants': [senderUid, receiverUid],
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error enviando audio: $e');
      rethrow;
    }
  }

  /// Enviar attachment (location, contact, document)
  static Future<void> sendAttachment({
    required String conversationId,
    required String content,
    required String type,
    required String senderUid,
    required String senderName,
    required String receiverUid,
  }) async {
    try {
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

      await _db.collection('conversations').doc(conversationId).set({
        'lastMessage':
            content.length > 40 ? '${content.substring(0, 40)}...' : content,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'participants': [senderUid, receiverUid],
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error enviando attachment: $e');
      rethrow;
    }
  }
}
