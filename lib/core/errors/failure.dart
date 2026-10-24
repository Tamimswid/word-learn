import 'package:flutter/foundation.dart';

enum FailureType {
  network,
  timeout,
  authentication,
  permission,
  notFound,
  conflict,
  storage,
  unexpected,
}

/// Common, user-facing error raised by repositories.
@immutable
class Failure {
  const Failure(
    this.message, {
    this.type = FailureType.unexpected,
    this.code,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final FailureType type;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Failure &&
            other.message == message &&
            other.type == type &&
            other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, type, code);

  @override
  String toString() => 'Failure($message, type: $type, code: $code)';
}
