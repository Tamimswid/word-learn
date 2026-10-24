import '../../data/models/exercise_item.dart';

extension ExerciseTypeX on ExerciseType {
  String get title => switch (this) {
    ExerciseType.trueFalse => 'Doğru / yanlış',
    ExerciseType.matching => 'Hızlı eşleştirme',
    ExerciseType.fillBlank => 'Boşluk doldurma',
    ExerciseType.spelling => 'Kelime tamamlama',
    ExerciseType.translation => 'Çeviriyi bul',
    ExerciseType.sentence => 'Cümle kurma',
  };

  String get level => switch (this) {
    ExerciseType.trueFalse || ExerciseType.matching => 'Süper hızlı',
    ExerciseType.fillBlank => 'Kolay',
    ExerciseType.spelling || ExerciseType.translation => 'Orta',
    ExerciseType.sentence => 'Zor',
  };

  String get duration => switch (this) {
    ExerciseType.trueFalse || ExerciseType.matching => '5–10 sn',
    ExerciseType.fillBlank => '15–20 sn',
    ExerciseType.spelling || ExerciseType.translation => '20–30 sn',
    ExerciseType.sentence => '30–45 sn',
  };
}
