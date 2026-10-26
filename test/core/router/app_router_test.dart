import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wordlearn/app/app.dart';
import 'package:wordlearn/core/di/app_locator.dart';
import 'package:wordlearn/core/router/router.dart';
import 'package:wordlearn/features/auth/data/models/auth_user.dart';
import 'package:wordlearn/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:wordlearn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wordlearn/features/home_dashboard/presentation/pages/home_page.dart';
import 'package:wordlearn/features/word_management/presentation/pages/all_words_page.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  final repository = InMemoryAuthRepository(
    initialUser: const AuthUser(
      id: 'u1',
      email: 'ayse@gmail.com',
      displayName: 'Ayşe Yılmaz',
    ),
  );
  final cubit = AuthCubit(repository)..initialize();

  addTearDown(repository.dispose);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(value: cubit, child: const WordlearnApp()),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(setupLocator);

  testWidgets('navigates to a feature route', (tester) async {
    await _pumpApp(tester);

    final context = tester.element(find.byType(HomePage));
    GoRouter.of(context).go(AppRoute.settings.path);
    await tester.pumpAndSettle();

    expect(find.byType(RoutePlaceholderPage), findsOneWidget);
    expect(find.text('settings'), findsOneWidget);
  });

  testWidgets('renders the all words route', (tester) async {
    await _pumpApp(tester);

    final context = tester.element(find.byType(HomePage));
    GoRouter.of(context).go(AppRoute.words.path);
    await tester.pumpAndSettle();

    expect(find.byType(AllWordsPage), findsOneWidget);
    expect(find.text('Tüm kelimeler'), findsOneWidget);
    expect(find.text('Henüz kelime yok'), findsOneWidget);
  });

  testWidgets('shows the error page for unknown locations', (tester) async {
    await _pumpApp(tester);

    final context = tester.element(find.byType(HomePage));
    GoRouter.of(context).go('/bilinmeyen');
    await tester.pumpAndSettle();

    expect(find.byType(RouteErrorPage), findsOneWidget);
    expect(find.text('Sayfa bulunamadı'), findsOneWidget);
  });
}
