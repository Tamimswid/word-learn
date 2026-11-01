import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/tutor_data_source.dart';
import '../models/chat_message.dart';
import '../models/tutor_opening.dart';
import '../models/tutor_reply.dart';
import '../models/tutor_session.dart';
import 'tutor_repository.dart';

class TutorRepositoryImpl implements TutorRepository {
  TutorRepositoryImpl(this._source);

  final TutorDataSource _source;

  static const Failure _badResponse = Failure(
    'تعذر الحصول على رد المعلم. يرجى المحاولة مرة أخرى.',
  );

  static const Failure _badSummary = Failure(
    'تعذر إنشاء ملخص المحادثة. يرجى المحاولة مرة أخرى.',
  );

  @override
  Future<Either<Failure, TutorOpening>> start() async {
    final result = await _source.start();

    return result.fold<Either<Failure, TutorOpening>>(
      (failure) {
        return Left(failure);
      },
      (payload) {
        final text = (payload['reply'] as String? ?? '').trim();
        if (text.isEmpty) {
          return const Left(_badResponse);
        }

        final session = payload['session'];
        final parsed = session is Map
            ? TutorSession.fromJson(Map<String, dynamic>.from(session))
            : const TutorSession();
        return Right(TutorOpening(text: text, session: parsed));
      },
    );
  }

  @override
  Future<Either<Failure, TutorReply>> respond({
    required String userMessage,
    required List<ChatMessage> history,
    required TutorSession session,
  }) async {
    final result = await _source.respond(
      userMessage: userMessage,
      history: history,
      session: session,
    );

    return result.fold<Either<Failure, TutorReply>>(
      (failure) {
        return Left(failure);
      },
      (payload) {
        final reply = TutorReply.tryParse(payload);
        if (reply == null) {
          return const Left(_badResponse);
        }
        return Right(reply);
      },
    );
  }

  @override
  Future<Either<Failure, String>> end({
    required List<ChatMessage> history,
    required TutorSession session,
  }) async {
    final result = await _source.end(history: history, session: session);

    return result.fold<Either<Failure, String>>(
      (failure) {
        return Left(failure);
      },
      (payload) {
        final summary = (payload['summary'] as String? ?? '').trim();
        if (summary.isEmpty) {
          return const Left(_badSummary);
        }
        return Right(summary);
      },
    );
  }
}
