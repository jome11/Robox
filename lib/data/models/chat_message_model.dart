class ChatMessage {
  final String id;
  final String taskId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'admin' or 'worker' — used for the sender label styling
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });
}
