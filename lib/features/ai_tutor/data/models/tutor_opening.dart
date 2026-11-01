import 'package:flutter/foundation.dart';

import 'tutor_session.dart';

/// What `start` returns: the teacher's first message plus the session data it
/// was built from.
@immutable
class TutorOpening {
  const TutorOpening({required this.text, required this.session});

  final String text;
  final TutorSession session;
}
