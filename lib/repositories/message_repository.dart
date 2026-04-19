import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _messages => _db.collection('messages');

  String _conversationId(String doctorId, String patientId) {
    final ids = [doctorId, patientId]..sort();
    return ids.join('_');
  }

  Stream<List<MessageModel>> watchMessages(String doctorId, String patientId) {
    final convId = _conversationId(doctorId, patientId);
    return _messages
        .doc(convId)
        .collection('chats')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String doctorId,
    required String patientId,
    required String senderId,
    required String content,
  }) async {
    final convId = _conversationId(doctorId, patientId);
    final now = Timestamp.now();

    final message = {
      'senderId': senderId,
      'receiverId': senderId == doctorId ? patientId : doctorId,
      'content': content,
      'type': 'text',
      'isRead': false,
      'createdAt': now,
    };

    await _messages.doc(convId).collection('chats').add(message);

    await _messages.doc(convId).set({
      'doctorId': doctorId,
      'patientId': patientId,
      'lastMessage': content,
      'lastMessageAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  Future<void> markMessagesAsRead(String doctorId, String patientId) async {
    final convId = _conversationId(doctorId, patientId);
    final unread = await _messages
        .doc(convId)
        .collection('chats')
        .where('isRead', isEqualTo: false)
        .where('receiverId', isEqualTo: doctorId)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> watchConversations(String doctorId) {
    return _messages
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList());
  }

  Future<int> getUnreadCount(String doctorId, String patientId) async {
    final convId = _conversationId(doctorId, patientId);
    final snap = await _messages
        .doc(convId)
        .collection('chats')
        .where('isRead', isEqualTo: false)
        .where('receiverId', isEqualTo: doctorId)
        .get();
    return snap.size;
  }
}
