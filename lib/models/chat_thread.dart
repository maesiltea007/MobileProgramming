import 'chat_message.dart';

class ChatThread {
  final String userId;
  final String designId;
  final List<ChatMessage> messages;

  ChatThread({
    required this.userId,
    required this.designId,
    required this.messages,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'designId': designId,
    'messages': messages.map((m) => m.toMap()).toList(),
  };

  factory ChatThread.fromMap(Map<String, dynamic> map) => ChatThread(
    userId: map['userId'] as String,
    designId: map['designId'] as String,
    messages: (map['messages'] as List)
        .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );
}