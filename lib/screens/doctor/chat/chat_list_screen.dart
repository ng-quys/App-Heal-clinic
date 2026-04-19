import 'package:flutter/material.dart';
import '../../../models/message_model.dart';
import '../../../repositories/patient_repository.dart';
import '../../../repositories/message_repository.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String doctorId;
  const ChatListScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    final messageRepo = MessageRepository();
    final patientRepo = PatientRepository();

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: messageRepo.watchConversations(doctorId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                final conversations = snap.data ?? [];
                if (conversations.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Chưa có cuộc trò chuyện nào',
                    icon: Icons.chat_bubble_outline_rounded,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: conversations.length,
                  itemBuilder: (context, i) {
                    final conv = conversations[i];
                    final patientId = conv['patientId'] as String? ?? '';
                    return FutureBuilder(
                      future: Future.wait([
                        patientRepo.getPatientById(patientId),
                        messageRepo.getUnreadCount(doctorId, patientId),
                      ]),
                      builder: (context, futureSnap) {
                        final patient = futureSnap.data?[0] as dynamic;
                        final unread = (futureSnap.data?[1] as int?) ?? 0;
                        final name = patient?.fullName ?? 'Bệnh nhân';
                        final initials = patient?.initials ?? '?';
                        final lastMsg = conv['lastMessage'] as String? ?? '';
                        final lastAt = (conv['lastMessageAt'] as dynamic)?.toDate() as DateTime?;

                        return _ConversationTile(
                          patientId: patientId,
                          patientName: name,
                          initials: initials,
                          lastMessage: lastMsg,
                          lastMessageAt: lastAt,
                          unreadCount: unread,
                          colorIndex: patientId.hashCode,
                          isFirst: i == 0,
                          isLast: i == conversations.length - 1,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                doctorId: doctorId,
                                patientId: patientId,
                                patientName: name,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text('Chat',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String initials;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final int colorIndex;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.patientId,
    required this.patientName,
    required this.initials,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.colorIndex,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                AvatarWidget(initials: initials, colorIndex: colorIndex),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(lastMessage,
                          style: TextStyle(
                              fontSize: 12,
                              color: unreadCount > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatTime(lastMessageAt),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$unreadCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
