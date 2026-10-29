import 'package:flutter/foundation.dart';

/// A notification bound to the moment it fires. Word reminders and app-entry
/// nudges share the shape; only their text differs.
@immutable
class ReminderSlot {
  const ReminderSlot({
    required this.title,
    required this.body,
    required this.at,
  });

  final String title;
  final String body;
  final DateTime at;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReminderSlot &&
            other.title == title &&
            other.body == body &&
            other.at == at;
  }

  @override
  int get hashCode => Object.hash(title, body, at);
}
