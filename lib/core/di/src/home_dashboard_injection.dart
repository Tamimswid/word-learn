import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/home_dashboard/data/data_sources/home_data_source.dart';
import '../../../features/home_dashboard/data/data_sources/in_memory_home_data_source.dart';
import '../../../features/home_dashboard/data/data_sources/supabase_home_data_source.dart';
import '../../../features/home_dashboard/data/repositories/home_repository_impl.dart';
import '../../../features/home_dashboard/home_dashboard.dart';
import '../../../features/word_management/word_management.dart';
import '../../data/supabase_client.dart';

void registerHomeDashboardDependencies(GetIt locator) {
  if (!locator.isRegistered<HomeDataSource>()) {
    locator.registerLazySingleton<HomeDataSource>(() {
      if (locator.isRegistered<SupabaseClient>() &&
          locator.isRegistered<AppSupabaseClient>()) {
        return SupabaseHomeDataSource(
          locator<SupabaseClient>(),
          locator<AppSupabaseClient>(),
        );
      }

      return InMemoryHomeDataSource();
    });
  }

  if (!locator.isRegistered<HomeRepository>()) {
    locator.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(locator<HomeDataSource>()),
    );
  }

  if (!locator.isRegistered<HomeCubit>()) {
    locator.registerFactory<HomeCubit>(
      () => HomeCubit(locator<HomeRepository>(), locator<WordRepository>()),
    );
  }
}
