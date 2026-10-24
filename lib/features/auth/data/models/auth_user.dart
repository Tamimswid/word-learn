import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  String get firstName {
    final parts = _nameParts;
    return parts.isEmpty ? '' : parts.first;
  }

  String get initials {
    final parts = _nameParts;
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    final first = parts.first.substring(0, 1);
    final last = parts.last.substring(0, 1);
    return '$first$last'.toUpperCase();
  }

  List<String> get _nameParts => displayName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthUser &&
            other.id == id &&
            other.email == email &&
            other.displayName == displayName &&
            other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, photoUrl);
}
