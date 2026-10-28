import 'package:get_it/get_it.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/quick_capture/data/data_sources/macos_selection_data_source.dart';
import '../../../features/quick_capture/data/data_sources/selection_data_source.dart';
import '../../../features/quick_capture/data/repositories/quick_capture_repository.dart';
import '../../../features/quick_capture/data/repositories/quick_capture_repository_impl.dart';
import '../../../features/quick_capture/presentation/cubit/quick_capture_cubit.dart';
import '../../../features/quick_capture/presentation/quick_capture_coordinator.dart';
import '../../../features/reminder/reminder.dart';
import '../../../features/word_management/data/repositories/word_repository.dart';

void registerQuickCaptureDependencies(GetIt locator) {
  if (!locator.isRegistered<SelectionDataSource>()) {
    locator.registerLazySingleton<SelectionDataSource>(
      MacosSelectionDataSource.new,
    );
  }

  if (!locator.isRegistered<QuickCaptureRepository>()) {
    locator.registerLazySingleton<QuickCaptureRepository>(
      () => QuickCaptureRepositoryImpl(
        locator<SelectionDataSource>(),
        locator<WordRepository>(),
      ),
    );
  }

  if (!locator.isRegistered<QuickCaptureCubit>()) {
    locator.registerLazySingleton<QuickCaptureCubit>(
      () => QuickCaptureCubit(locator<QuickCaptureRepository>()),
    );
  }

  if (!locator.isRegistered<QuickCaptureCoordinator>()) {
    locator.registerLazySingleton<QuickCaptureCoordinator>(
      () => QuickCaptureCoordinator(
        locator<QuickCaptureRepository>(),
        locator<QuickCaptureCubit>(),
        locator<AuthCubit>(),
        locator<ReminderRepository>(),
      ),
    );
  }
}
