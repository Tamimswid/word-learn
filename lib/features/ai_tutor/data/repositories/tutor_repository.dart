import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/chat_message.dart';
import '../models/tutor_opening.dart';
import '../models/tutor_reply.dart';
import '../models/tutor_session.dart';

/// Typed tutor conversation operations for the presentation layer.
abstract interface class TutorRepository {
  Future<Either<Failure, TutorOpening>> start();

  Future<Either<Failure, TutorReply>> respond({
    required String userMessage,
    required List<ChatMessage> history,
    required TutorSession session,
  });

  Future<Either<Failure, String>> end({
    required List<ChatMessage> history,
    required TutorSession session,
  });
}
