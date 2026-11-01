import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import '../models/chat_message.dart';
import '../models/tutor_session.dart';
import 'tutor_data_source.dart';

class SupabaseTutorDataSource implements TutorDataSource {
  SupabaseTutorDataSource(this._client);

  final SupabaseClient _client;

  static const String _function = 'ai-tutor';

  static const Failure _sessionFailure = Failure(
    'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
    type: FailureType.authentication,
  );

  static const Failure _tutorFailure = Failure(
    'تعذر الحصول على رد المعلم. يرجى المحاولة مرة أخرى.',
  );

  @override
  Future<Either<Failure, Map<String, dynamic>>> start() {
    return _invoke(<String, Object?>{'action': 'start'});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> respond({
    required String userMessage,
    required List<ChatMessage> history,
    required TutorSession session,
  }) {
    return _invoke(<String, Object?>{
      'action': 'respond',
      'userMessage': userMessage,
      'messages': _toWire(history),
      ...session.toWire(),
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> end({
    required List<ChatMessage> history,
    required TutorSession session,
  }) {
    return _invoke(<String, Object?>{
      'action': 'end',
      'messages': _toWire(history),
      ...session.toWire(),
    });
  }

  static List<Map<String, String>> _toWire(List<ChatMessage> history) {
    return history.map((message) => message.toWire()).toList(growable: false);
  }

  Future<Either<Failure, Map<String, dynamic>>> _invoke(
    Map<String, Object?> body,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const Left(_sessionFailure);
    }

    try {
      final response = await _client.functions.invoke(_function, body: body);

      final payload = response.data;
      if (payload is! Map || payload['success'] != true) {
        return const Left(_tutorFailure);
      }

      return Right(Map<String, dynamic>.from(payload));
    } catch (error, stackTrace) {
      final failure = SupabaseErrorHandler.map(
        error,
        stackTrace: stackTrace,
        fallbackMessage: _tutorFailure.message,
      );
      return Left(failure);
    }
  }
}
