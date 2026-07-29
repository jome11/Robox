class ChatMessage {
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessage({
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });
}
