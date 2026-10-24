import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/micro_exercise/data/data_sources/exercise_data_source.dart';
import '../../../features/micro_exercise/data/data_sources/in_memory_exercise_data_source.dart';
import '../../../features/micro_exercise/data/data_sources/supabase_exercise_data_source.dart';
import '../../../features/micro_exercise/data/repositories/exercise_repository_impl.dart';
import '../../../features/micro_exercise/micro_exercise.dart';
import '../../data/supabase_client.dart';

void registerMicroExerciseDependencies(GetIt locator) {
  if (!locator.isRegistered<ExerciseDataSource>()) {
    locator.registerLazySingleton<ExerciseDataSource>(() {
      if (locator.isRegistered<SupabaseClient>() &&
          locator.isRegistered<AppSupabaseClient>()) {
        return SupabaseExerciseDataSource(
          locator<SupabaseClient>(),
          locator<AppSupabaseClient>(),
        );
      }

      return InMemoryExerciseDataSource();
    });
  }

  if (!locator.isRegistered<ExerciseRepository>()) {
    locator.registerLazySingleton<ExerciseRepository>(
      () => ExerciseRepositoryImpl(locator<ExerciseDataSource>()),
    );
  }

  if (!locator.isRegistered<ExerciseCubit>()) {
    locator.registerFactory<ExerciseCubit>(
      () => ExerciseCubit(locator<ExerciseRepository>()),
    );
  }
}
