import 'package:flutter/material.dart';
import '../../../models/message_model.dart';
import '../../../services/chat_service.dart';
import '../../../theme.dart';
import '../../../widgets/common/common_widgets.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String patientName;

  const ChatScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _chatService.markAsRead(widget.doctorId, widget.patientId);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _inputCtrl.clear();

    try {
      await _chatService.sendMessage(
        doctorId: widget.doctorId,
        patientId: widget.patientId,
        content: text,
      );
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.watchMessages(
                  widget.doctorId, widget.patientId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }
                final messages = snap.data ?? [];
                if (messages.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'Bắt đầu cuộc trò chuyện',
                    icon: Icons.chat_outlined,
                  );
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return _buildMessageList(messages);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final initials = () {
      final parts = widget.patientName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return widget.patientName.isNotEmpty
          ? widget.patientName[0].toUpperCase()
          : '?';
    }();

    return AppBar(
      leading: const BackButton(),
      title: Row(
        children: [
          AvatarWidget(
            initials: initials,
            colorIndex: widget.patientId.hashCode,
            size: 34,
            fontSize: 12,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.patientName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const Text('Đang online',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.success)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageList(List<MessageModel> messages) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final msg = messages[i];
        final isMe = msg.senderId == widget.doctorId;
        final showDate = i == 0 ||
            _isDifferentDay(messages[i - 1].createdAt, msg.createdAt);

        return Column(
          children: [
            if (showDate) _DateDivider(date: msg.createdAt),
            _MessageBubble(message: msg, isMe: isMe),
          ],
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _inputCtrl,
                onSubmitted: (_) => _send(),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Nhắn tin...',
                  hintStyle:
                      TextStyle(color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  String _label() {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(_label(),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          Radius.circular(isMe ? 16 : 4),
                      bottomRight:
                          Radius.circular(isMe ? 4 : 16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(timeStr,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary)),
              if (isMe) ...[
                const SizedBox(width: 3),
                Icon(
                  message.isRead ? Icons.done_all : Icons.done,
                  size: 12,
                  color:
                      message.isRead ? AppColors.primary : AppColors.textHint,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
