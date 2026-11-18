import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/diary_feelings_view.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  group('DiaryFeelingsView Widget Tests (Figma Specs)', () {
    late LocalDiaryRepository repository;
    late DiaryController controller;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
      controller = DiaryController(repository: repository);
    });

    Widget createWidgetUnderTest({Humor? initialHumor}) {
      return MaterialApp(
        home: DiaryFeelingsView(
          key: ValueKey(initialHumor),
          controller: controller,
          initialHumor: initialHumor,
        ),
      );
    }

    testWidgets('renders all Figma elements: back button, title, label, central face, chevron down, wheel, needle, save button', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Back button
      expect(find.byKey(const Key('diary_back_button')), findsOneWidget);

      // Title
      expect(find.text('Como você está\nse sentindo hoje?'), findsOneWidget);

      // Selected emotion label (default Neutro)
      expect(find.byKey(const Key('selected_emotion_label')), findsOneWidget);
      expect(find.text('Neutro'), findsOneWidget);

      // Central emotion face (120px) with EmotionFacePainter
      expect(find.byKey(const Key('central_emotion_face')), findsOneWidget);
      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('central_emotion_custom_paint')),
      );
      expect(customPaint.painter, isA<EmotionFacePainter>());
      expect((customPaint.painter as EmotionFacePainter).humor, Humor.neutro);

      // Needle pointer
      expect(find.byKey(const Key('needle_pointer')), findsOneWidget);

      // Save button inside wheel center
      expect(find.byKey(const Key('save_humor_button')), findsOneWidget);
      expect(find.text('Salvar Neutro'), findsOneWidget);
    });

    testWidgets('tap save button persists emotion in DiaryController and shows confirmation', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(initialHumor: Humor.neutro));
      await tester.pumpAndSettle();

      expect(controller.entries.isEmpty, isTrue);

      await tester.tap(find.byKey(const Key('save_humor_button')));
      await tester.pumpAndSettle();

      expect(controller.entries.length, 1);
      expect(controller.latestEntry?.humor, Humor.neutro);
      expect(find.textContaining('Neutro registrado!'), findsOneWidget);
    });

    testWidgets('com registro hoje, abre no humor do dia e salvar altera em vez de criar outro', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await repository.save(RegistroDiario(
        id: 'hoje',
        humor: Humor.feliz,
        dataHora: DateTime.now(),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Alterar para Feliz'), findsOneWidget);
      expect(find.byKey(const Key('registro_hoje_aviso')), findsOneWidget);

      await tester.tap(find.byKey(const Key('save_humor_button')));
      await tester.pumpAndSettle();

      expect(controller.entries.length, 1);
      expect(controller.entries.single.id, 'hoje');
      expect(find.textContaining('Humor de hoje alterado para Feliz'), findsOneWidget);
    });

    testWidgets('sem registro hoje não mostra o aviso', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('registro_hoje_aviso')), findsNothing);
    });

    testWidgets('tap central face persists emotion in DiaryController', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(initialHumor: Humor.feliz));
      await tester.pumpAndSettle();

      expect(controller.entries.isEmpty, isTrue);

      await tester.tap(find.byKey(const Key('central_emotion_face')));
      await tester.pumpAndSettle();

      expect(controller.entries.length, 1);
      expect(controller.latestEntry?.humor, Humor.feliz);
    });

    testWidgets('tap needle pointer persists emotion in DiaryController', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(initialHumor: Humor.triste));
      await tester.pumpAndSettle();

      expect(controller.entries.isEmpty, isTrue);

      await tester.tap(find.byKey(const Key('needle_pointer')));
      await tester.pumpAndSettle();

      expect(controller.entries.length, 1);
      expect(controller.latestEntry?.humor, Humor.triste);
    });

    testWidgets('tap back chevron button calls Navigator.maybePop', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiaryFeelingsView(controller: controller),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Como você está\nse sentindo hoje?'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('diary_back_button')));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('wheel drag updates selection and emotion label from any finger position (top arc and lateral edges)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(initialHumor: Humor.neutro));
      await tester.pumpAndSettle();

      // 1. Drag from the upper arc of the wheel (y = 590, previously outside GestureDetector bounds)
      await tester.dragFrom(const Offset(260, 590), const Offset(-140, 20));
      await tester.pumpAndSettle();
      expect(controller.selectedHumor, isNot(Humor.neutro));

      // 2. Drag from the far left lateral edge with a strong vertical component
      final previousHumor = controller.selectedHumor;
      await tester.dragFrom(const Offset(50, 720), const Offset(130, -90));
      await tester.pumpAndSettle();
      expect(controller.selectedHumor, isNot(previousHumor));
    });

    testWidgets('tapping on wheel ring area triggers emotion selection', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(initialHumor: Humor.neutro));
      await tester.pumpAndSettle();

      // Tap to the right of the center on the green/feliz sector (around x=300, y=700)
      await tester.tapAt(const Offset(300, 700));
      await tester.pumpAndSettle();

      expect(controller.selectedHumor, isNotNull);
    });

    testWidgets('renders cleanly without overflow on narrow device (320x640)', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Como você está\nse sentindo hoje?'), findsOneWidget);
    });

    testWidgets('renders all 6 emotions correctly with corresponding wheelColor', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final humor in Humor.values) {
        await tester.pumpWidget(createWidgetUnderTest(initialHumor: humor));
        await tester.pumpAndSettle();

        expect(find.text(humor.label), findsWidgets);
        expect(humor.wheelColor, isNotNull);
      }
    });
  });
}
