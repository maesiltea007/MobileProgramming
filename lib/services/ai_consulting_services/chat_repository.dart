import 'package:hive/hive.dart';
import '../../models/chat_message.dart';
import '../../models/chat_thread.dart';

class ChatRepository {
  static final Box _box = Hive.box('chatbox');   // ⭐ NEW: chatbox 사용

  static String _threadKey(String userId, String designId) {
    return '$userId-$designId';
  }

  static ChatThread getThread(String userId, String designId) {
    final key = _threadKey(userId, designId);

    final raw = _box.get(key);
    if (raw == null) {
      return ChatThread(
        userId: userId,
        designId: designId,
        messages: [],
      );
    }

    final list = (raw as List).map((e) {
      return Map<String, dynamic>.from(e);
    }).toList();

    final messages = list.map((m) => ChatMessage.fromMap(m)).toList();

    return ChatThread(
      userId: userId,
      designId: designId,
      messages: messages,
    );
  }

  static void addMessage(String userId, String designId, ChatMessage msg) {
    final key = _threadKey(userId, designId);

    final raw = _box.get(key);

    List<Map<String, dynamic>> list;

    if (raw == null) {
      list = [];
    } else {
      list = (raw as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }

    list.add(msg.toMap());

    _box.put(key, list);
  }

// reset chating
  static void clearThread(String userId, String designId) {
    final key = _threadKey(userId, designId);
    _box.delete(key);
  }
}