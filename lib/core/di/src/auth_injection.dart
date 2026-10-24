import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/auth/data/repositories/auth_repository.dart';
import '../../../features/auth/data/repositories/in_memory_auth_repository.dart';
import '../../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../../features/auth/data/services/google_sign_in_service.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../config/app_config.dart';

void registerAuthDependencies(GetIt locator) {
  if (!locator.isRegistered<GoogleSignInService>()) {
    locator.registerLazySingleton<GoogleSignInService>(
      () => GoogleSignInService(
        webClientId: AppConfig.googleWebClientId,
        iosClientId: AppConfig.googleIosClientId,
      ),
    );
  }

  if (!locator.isRegistered<AuthRepository>()) {
    locator.registerLazySingleton<AuthRepository>(
      () {
        if (locator.isRegistered<SupabaseClient>()) {
          return SupabaseAuthRepository(
            locator<SupabaseClient>(),
            locator<GoogleSignInService>(),
          );
        }
        return InMemoryAuthRepository();
      },
      dispose: (repository) {
        if (repository is InMemoryAuthRepository) repository.dispose();
      },
    );
  }

  if (!locator.isRegistered<AuthCubit>()) {
    locator.registerLazySingleton<AuthCubit>(
      () => AuthCubit(locator<AuthRepository>())..initialize(),
      dispose: (cubit) => cubit.close(),
    );
  }
}
