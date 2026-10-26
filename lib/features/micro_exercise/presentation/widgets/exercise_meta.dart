import '../../data/models/exercise_item.dart';

extension ExerciseTypeX on ExerciseType {
  String get title => switch (this) {
    ExerciseType.matching => 'Çeviri–anlam eşleştirme',
    ExerciseType.fillBlank => 'Boşluk doldurma',
    ExerciseType.spelling => 'Kelime tamamlama',
    ExerciseType.translation => 'Çeviriyi bul',
    ExerciseType.pronunciation => 'Telaffuz',
  };

  String get level => switch (this) {
    ExerciseType.matching || ExerciseType.fillBlank => 'Kolay',
    ExerciseType.spelling ||
    ExerciseType.translation ||
    ExerciseType.pronunciation => 'Orta',
  };

  String get duration => switch (this) {
    ExerciseType.pronunciation => '10–15 sn',
    ExerciseType.matching => '15–25 sn',
    ExerciseType.fillBlank => '15–20 sn',
    ExerciseType.spelling || ExerciseType.translation => '20–30 sn',
  };
}
