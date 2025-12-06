import 'package:flutter/material.dart';

import '../../../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final alignment =
    isUser ? Alignment.centerRight : Alignment.centerLeft;

    final bgColor =
    isUser ? Colors.grey.shade300 : Colors.black;

    final textColor =
    isUser ? Colors.black : Colors.white;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: const BoxConstraints(
          maxWidth: 280, // 화면 꽉 채우지 않게
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}