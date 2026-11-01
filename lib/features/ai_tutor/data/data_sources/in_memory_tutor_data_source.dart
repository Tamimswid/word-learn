import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/chat_message.dart';
import '../models/tutor_session.dart';
import 'tutor_data_source.dart';

/// Offline placeholder used when Supabase is not configured. It returns empty
/// payloads, so the repository turns every tutor call into a readable failure.
class InMemoryTutorDataSource implements TutorDataSource {
  @override
  Future<Either<Failure, Map<String, dynamic>>> start() async {
    return const Right(<String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> respond({
    required String userMessage,
    required List<ChatMessage> history,
    required TutorSession session,
  }) async {
    return const Right(<String, dynamic>{});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> end({
    required List<ChatMessage> history,
    required TutorSession session,
  }) async {
    return const Right(<String, dynamic>{});
  }
}
