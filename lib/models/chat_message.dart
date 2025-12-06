class ChatMessage {
  final bool isUser;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.isUser,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'isUser': isUser,
    'text': text,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    isUser: map['isUser'] as bool,
    text: map['text'] as String,
    createdAt:
    DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );
}