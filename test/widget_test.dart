import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordlearn/app/app.dart';
import 'package:wordlearn/core/design_system/design_system.dart';
import 'package:wordlearn/core/di/app_locator.dart';
import 'package:wordlearn/core/widgets/widgets.dart';
import 'package:wordlearn/features/auth/data/models/auth_user.dart';
import 'package:wordlearn/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:wordlearn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wordlearn/features/home_dashboard/presentation/widgets/activity_bar_chart.dart';

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

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('home dashboard renders', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Kelime'), findsOneWidget);
    expect(find.text('Merhaba, Ayşe'), findsOneWidget);
    expect(find.text('Bugün de bir kelime.'), findsOneWidget);
    expect(find.text('0 gün · 1 giriş'), findsOneWidget);
    expect(find.text('Öğrenme ritmin'), findsOneWidget);
    expect(find.byType(ActivityBarChart), findsOneWidget);
    expect(find.text('Hızlı alıştırma'), findsNothing);
    expect(find.text('Süper hızlı'), findsNothing);
    expect(find.text('Son öğrenilenler'), findsOneWidget);
    expect(find.text('Tümünü gör'), findsNothing);
    expect(find.image(const AssetImage(AppAssets.empty)), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
    expect(find.widgetWithText(AppAddButton, 'Kelime ekle'), findsOneWidget);

    final context = tester.element(find.byType(AppCard).first);
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.background);
  });

  testWidgets('home fits a 390 px phone', (tester) async {
    final fontLoader = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await fontLoader.load();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('adds a word from the recent words dialog', (tester) async {
    await _pumpApp(tester);

    final addButton = find.widgetWithText(AppAddButton, 'Kelime ekle');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Kelimeyi gir; anlamını istersen kendin yazabilirsin.'),
      findsOneWidget,
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'resilient');
    await tester.enterText(fields.at(1), 'dayanıklı');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();

    expect(find.text('resilient'), findsOneWidget);
    expect(find.text('dayanıklı'), findsOneWidget);

    final viewAll = find.text('Tümünü gör');
    await tester.ensureVisible(viewAll);
    await tester.pumpAndSettle();
    await tester.tap(viewAll);
    await tester.pumpAndSettle();

    expect(find.text('Tüm kelimeler'), findsOneWidget);
    expect(find.text('resilient'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('0 doğru'), findsOneWidget);
    expect(find.text('0 yanlış'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('deletes a word after swiping right and confirming', (
    tester,
  ) async {
    await _pumpApp(tester);

    final addButton = find.widgetWithText(AppAddButton, 'Kelime ekle');
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'resilient');
    await tester.enterText(fields.at(1), 'dayanıklı');
    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();

    final row = find.text('resilient');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.drag(row, const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Kelimeyi sil'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Sil'));
    await tester.pumpAndSettle();

    expect(find.text('resilient'), findsNothing);
    expect(find.text('Empty'), findsOneWidget);
  });

  testWidgets('session size sheet saves the selection', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();

    expect(find.text('Oturum başına kelime'), findsOneWidget);
    expect(find.text('Özel'), findsOneWidget);

    await tester.tap(find.text('20'));
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(
      find.text('Oturum başına 20 kelime olarak kaydedildi.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
