import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/word_management/data/data_sources/in_memory_word_data_source.dart';
import '../../../features/word_management/data/data_sources/supabase_word_data_source.dart';
import '../../../features/word_management/data/data_sources/word_data_source.dart';
import '../../../features/word_management/data/repositories/word_repository_impl.dart';
import '../../../features/word_management/word_management.dart';
import '../../data/supabase_client.dart';

void registerWordManagementDependencies(GetIt locator) {
  if (!locator.isRegistered<WordDataSource>()) {
    locator.registerLazySingleton<WordDataSource>(() {
      if (locator.isRegistered<SupabaseClient>() &&
          locator.isRegistered<AppSupabaseClient>()) {
        return SupabaseWordDataSource(
          locator<SupabaseClient>(),
          locator<AppSupabaseClient>(),
        );
      }

      return InMemoryWordDataSource();
    });
  }

  if (!locator.isRegistered<WordRepository>()) {
    locator.registerLazySingleton<WordRepository>(
      () => WordRepositoryImpl(locator<WordDataSource>()),
    );
  }

  if (!locator.isRegistered<AddWordCubit>()) {
    locator.registerFactory<AddWordCubit>(
      () => AddWordCubit(locator<WordRepository>()),
    );
  }

  if (!locator.isRegistered<WordListCubit>()) {
    locator.registerFactory<WordListCubit>(
      () => WordListCubit(locator<WordRepository>()),
    );
  }
}
