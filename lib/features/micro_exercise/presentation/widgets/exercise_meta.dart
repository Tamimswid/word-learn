import '../../data/models/exercise_item.dart';

extension ExerciseTypeX on ExerciseType {
  String get title => switch (this) {
    ExerciseType.matching => 'مطابقة الترجمة بالمعنى',
    ExerciseType.fillBlank => 'ملء الفراغ',
    ExerciseType.spelling => 'إكمال الكلمة',
    ExerciseType.translation => 'اعثر على الترجمة',
    ExerciseType.pronunciation => 'النطق',
  };

  String get level => switch (this) {
    ExerciseType.matching || ExerciseType.fillBlank => 'سهل',
    ExerciseType.spelling ||
    ExerciseType.translation ||
    ExerciseType.pronunciation => 'متوسط',
  };

  String get duration => switch (this) {
    ExerciseType.pronunciation => '10–15 ث',
    ExerciseType.matching => '15–25 ث',
    ExerciseType.fillBlank => '15–20 ث',
    ExerciseType.spelling || ExerciseType.translation => '20–30 ث',
  };
}
