import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/ai_tutor/data/data_sources/in_memory_tutor_data_source.dart';
import '../../../features/ai_tutor/data/data_sources/supabase_tutor_data_source.dart';
import '../../../features/ai_tutor/data/data_sources/tutor_data_source.dart';
import '../../../features/ai_tutor/data/repositories/tutor_repository_impl.dart';
import '../../../features/ai_tutor/ai_tutor.dart';

void registerAiTutorDependencies(GetIt locator) {
  if (!locator.isRegistered<TutorDataSource>()) {
    locator.registerLazySingleton<TutorDataSource>(() {
      if (locator.isRegistered<SupabaseClient>()) {
        return SupabaseTutorDataSource(locator<SupabaseClient>());
      }

      return InMemoryTutorDataSource();
    });
  }

  if (!locator.isRegistered<TutorRepository>()) {
    locator.registerLazySingleton<TutorRepository>(
      () => TutorRepositoryImpl(locator<TutorDataSource>()),
    );
  }

  if (!locator.isRegistered<TutorCubit>()) {
    locator.registerFactory<TutorCubit>(
      () => TutorCubit(locator<TutorRepository>()),
    );
  }
}
