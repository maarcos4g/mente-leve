import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/diary/widgets/mood_selector_card.dart';

void main() {
  group('MoodSelectorCard Widget Tests', () {
    late LocalDiaryRepository repository;
    late DiaryController controller;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
      controller = DiaryController(repository: repository);
    });

    Widget createWidgetUnderTest({VoidCallback? onCvvTap}) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MoodSelectorCard(
              controller: controller,
              onCvvTap: onCvvTap,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all 6 mood emojis and title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Como está sua mente hoje?'), findsOneWidget);
      for (final humor in Humor.values) {
        expect(find.text(humor.label), findsOneWidget);
        expect(find.text(humor.emoji), findsOneWidget);
      }
      expect(find.text('Selecione um emoji acima'), findsOneWidget);
    });

    testWidgets('complete 3-interaction flow: open -> tap emoji -> tap salvar', (tester) async {
      bool cvvTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(onCvvTap: () => cvvTapped = true));

      // 1. Initial interaction state
      expect(controller.interactionCount, 1);
      expect(controller.isReadyToSave, isFalse);

      // 2. Tap an emoji (Triste)
      await tester.tap(find.text('Triste'));
      await tester.pumpAndSettle();

      expect(controller.selectedHumor, Humor.triste);
      expect(controller.interactionCount, 2);
      expect(find.text('Salvar Triste'), findsOneWidget);

      // 3. Tap Salvar
      await tester.tap(find.text('Salvar Triste'));
      await tester.pumpAndSettle();

      expect(controller.interactionCount, 3);
      expect(controller.isSaved, isTrue);
      expect(find.text('Sentimento registrado!'), findsOneWidget);
      expect(find.text(Humor.triste.comfortingMessage), findsOneWidget);

      // As Triste is a critical mood, CVV 188 prompt is displayed
      expect(find.text('Ligar 188'), findsOneWidget);
      await tester.tap(find.text('Ligar 188'));
      expect(cvvTapped, isTrue);
    });

    testWidgets('renders cleanly without overflow on very narrow screen (320px)', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // All 6 emotions render
      for (final humor in Humor.values) {
        expect(find.text(humor.label), findsOneWidget);
      }

      expect(tester.takeException(), isNull);
    });
  });
}
