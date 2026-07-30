import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/chat_message_model.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;
  const ChatScreen({super.key, required this.taskId, required this.taskTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      senderName: 'Admin',
      content: 'Team, please prioritize the Node 7 calibration. We need it stable by EOD.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isMe: false,
    ),
    ChatMessage(
      senderName: 'Worker Alpha',
      content: 'Understood. I\'m currently running the diagnostics.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isMe: false,
    ),
    ChatMessage(
      senderName: 'Worker Beta',
      content: 'I\'ve prepared the replacement sensors if the diagnostics fail.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isMe: false,
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          senderName: 'Me',
          content: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.taskTitle.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.primary)),
            Text('TASK ID: ${widget.taskId}', style: AppTextStyles.label.copyWith(fontSize: 10)),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.send, color: AppColors.onPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.senderName.toUpperCase(),
                style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.primary),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isMe ? 16 : 0),
                bottomRight: Radius.circular(message.isMe ? 0 : 16),
              ),
              border: Border.all(
                color: message.isMe ? Colors.transparent : AppColors.border,
              ),
            ),
            child: Text(
              message.content,
              style: AppTextStyles.body.copyWith(
                color: message.isMe ? AppColors.onPrimary : AppColors.text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: AppTextStyles.label.copyWith(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}
