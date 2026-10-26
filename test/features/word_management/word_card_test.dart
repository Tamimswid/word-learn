import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/design_system/design_system.dart';
import 'package:wordlearn/features/word_management/data/models/word_summary.dart';
import 'package:wordlearn/features/word_management/presentation/widgets/word_card.dart';

void main() {
  testWidgets('renders the word, example, counters and rank', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: WordCard(
              word: WordSummary(
                id: 'w1',
                word: 'resilient',
                translation: 'dayanıklı',
                exampleSentence: 'She is resilient.',
                errorCount: 2,
                successCount: 5,
                rank: 7,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('resilient'), findsOneWidget);
    expect(find.text('dayanıklı'), findsOneWidget);
    expect(find.text('She is resilient.'), findsOneWidget);
    expect(find.text('#7'), findsOneWidget);
    expect(find.text('5 doğru'), findsOneWidget);
    expect(find.text('2 yanlış'), findsOneWidget);
  });
}
