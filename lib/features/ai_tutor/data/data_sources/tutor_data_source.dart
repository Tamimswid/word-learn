import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/chat_message.dart';
import '../models/tutor_session.dart';

/// Raw `ai-tutor` Edge Function responses; parsing lives in the repository.
abstract interface class TutorDataSource {
  Future<Either<Failure, Map<String, dynamic>>> start();

  Future<Either<Failure, Map<String, dynamic>>> respond({
    required String userMessage,
    required List<ChatMessage> history,
    required TutorSession session,
  });

  Future<Either<Failure, Map<String, dynamic>>> end({
    required List<ChatMessage> history,
    required TutorSession session,
  });
}
