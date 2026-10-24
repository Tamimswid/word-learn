import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/deck_session/data/data_sources/deck_data_source.dart';
import '../../../features/deck_session/data/data_sources/in_memory_deck_data_source.dart';
import '../../../features/deck_session/data/data_sources/supabase_deck_data_source.dart';
import '../../../features/deck_session/data/repositories/deck_repository_impl.dart';
import '../../../features/deck_session/deck_session.dart';
import '../../data/supabase_client.dart';

void registerDeckSessionDependencies(GetIt locator) {
  if (!locator.isRegistered<DeckDataSource>()) {
    locator.registerLazySingleton<DeckDataSource>(() {
      if (locator.isRegistered<SupabaseClient>() &&
          locator.isRegistered<AppSupabaseClient>()) {
        return SupabaseDeckDataSource(
          locator<SupabaseClient>(),
          locator<AppSupabaseClient>(),
        );
      }

      return InMemoryDeckDataSource();
    });
  }

  if (!locator.isRegistered<DeckRepository>()) {
    locator.registerLazySingleton<DeckRepository>(
      () => DeckRepositoryImpl(locator<DeckDataSource>()),
    );
  }

  if (!locator.isRegistered<DeckCubit>()) {
    locator.registerFactory<DeckCubit>(
      () => DeckCubit(locator<DeckRepository>()),
    );
  }
}
