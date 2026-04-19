import '../models/message_model.dart';
import '../repositories/message_repository.dart';
import '../repositories/patient_repository.dart';

class ChatService {
  final MessageRepository _messageRepository;
  final PatientRepository _patientRepository;

  ChatService({
    MessageRepository? messageRepository,
    PatientRepository? patientRepository,
  })  : _messageRepository = messageRepository ?? MessageRepository(),
        _patientRepository = patientRepository ?? PatientRepository();

  Stream<List<MessageModel>> watchMessages(String doctorId, String patientId) {
    return _messageRepository.watchMessages(doctorId, patientId);
  }

  Future<void> sendMessage({
    required String doctorId,
    required String patientId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;
    await _messageRepository.sendMessage(
      doctorId: doctorId,
      patientId: patientId,
      senderId: doctorId,
      content: content.trim(),
    );
  }

  Future<void> markAsRead(String doctorId, String patientId) async {
    await _messageRepository.markMessagesAsRead(doctorId, patientId);
  }

  Stream<List<Map<String, dynamic>>> watchConversations(String doctorId) {
    return _messageRepository.watchConversations(doctorId);
  }

  Future<List<ConversationModel>> getConversationsWithPatients(
      String doctorId) async {
    final conversations = await _messageRepository
        .watchConversations(doctorId)
        .first;

    final List<ConversationModel> result = [];
    for (final conv in conversations) {
      final patientId = conv['patientId'] as String? ?? '';
      final patient = await _patientRepository.getPatientById(patientId);
      final unread = await _messageRepository.getUnreadCount(doctorId, patientId);

      result.add(ConversationModel(
        conversationId: conv['id'] as String,
        patientId: patientId,
        patientName: patient?.fullName ?? 'Bệnh nhân',
        patientInitials: patient?.initials ?? '?',
        lastMessage: conv['lastMessage'] as String? ?? '',
        lastMessageAt: (conv['lastMessageAt'] as dynamic)?.toDate() ?? DateTime.now(),
        unreadCount: unread,
      ));
    }
    return result;
  }
}
