import 'package:flutter/foundation.dart';

enum ChatRole { teacher, user }

/// One line of the conversation.
///
/// The tutor function expects the assistant turns under the `assistant` role,
/// which is why the wire form is derived instead of stored.
@immutable
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.teacher(String content) {
    return ChatMessage(role: ChatRole.teacher, content: content);
  }

  factory ChatMessage.user(String content) {
    return ChatMessage(role: ChatRole.user, content: content);
  }

  final ChatRole role;
  final String content;

  bool get isTeacher => role == ChatRole.teacher;

  Map<String, String> toWire() {
    return <String, String>{
      'role': role == ChatRole.user ? 'user' : 'assistant',
      'content': content,
    };
  }
}
