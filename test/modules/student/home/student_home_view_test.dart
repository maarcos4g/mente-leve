import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/home/student_home_view.dart';

void main() {
  group('StudentHomeView Widget Tests (Figma Specs)', () {
    late LocalDiaryRepository repository;
    late DiaryController controller;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
      controller = DiaryController(repository: repository);
    });

    Widget createWidgetUnderTest({String nickname = 'Panda'}) {
      return MaterialApp(
        home: StudentHomeView(
          initialNickname: nickname,
          controller: controller,
        ),
      );
    }

    testWidgets('renders all Figma components: header, greeting, button, cards and CVV', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(nickname: 'Lucas'));
      await tester.pumpAndSettle();

      // Header greeting
      expect(find.text('Olá,\nLucas!'), findsOneWidget);

      // Central floating button (Frame 101)
      expect(find.text('Como está sua mente hoje?'), findsOneWidget);

      // Resumo da semana
      expect(find.text('Resumo da semana'), findsOneWidget);

      // Diário Pessoal card (Frame 103)
      expect(find.text('Diário Pessoal'), findsOneWidget);

      // Chat Anônimo card (Group 104)
      expect(find.text('Chat Anônimo'), findsOneWidget);

      // Canais de Apoio & FAQ card (Frame 105)
      expect(find.text('Canais de Apoio & FAQ'), findsOneWidget);

      // Emergency CVV button
      expect(find.text('Ajuda (CVV)'), findsOneWidget);
    });

    testWidgets('tapping Ajuda (CVV) opens emergency modal dialog', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ajuda (CVV)'));
      await tester.pumpAndSettle();

      expect(find.text('CVV 188 — Centro de Valorização da Vida'), findsOneWidget);
      expect(find.text('Ligar 188 agora'), findsOneWidget);

      // Tap ligar now
      await tester.tap(find.text('Ligar 188 agora'));
      await tester.pumpAndSettle();

      expect(find.text('Discaremos para 188 (CVV gratuito)'), findsOneWidget);
    });

    testWidgets('tapping Chat Anônimo card opens information dialog', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('card_chat_anonimo')));
      await tester.pumpAndSettle();

      expect(find.text('Converse com a equipe de apoio da escola de forma 100% anônima e segura. Suas conversas não revelam seu nome ou identidade.'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);

      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Canais de Apoio & FAQ card opens FAQ dialog', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('card_canais_apoio_faq')));
      await tester.pumpAndSettle();

      expect(find.text('Como funciona o anonimato?'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);

      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Como está sua mente hoje opens DiaryFeelingsView', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('button_como_esta_sua_mente')));
      await tester.pumpAndSettle();

      // Verify DiaryFeelingsView opened
      expect(find.text('Como você está\nse sentindo hoje?'), findsOneWidget);
      expect(find.text('Neutro'), findsOneWidget);
    });

    testWidgets('Resumo da semana updates when mood entry is saved', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum registro'), findsOneWidget);

      // Save a mood in controller
      controller.selectHumor(Humor.feliz);
      await controller.saveHumor();
      await tester.pumpAndSettle();

      expect(find.text('1 registro(s)'), findsOneWidget);
    });

    testWidgets('tapping Diário Pessoal card opens DiaryFeelingsView', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('card_diario_pessoal')));
      await tester.pumpAndSettle();

      expect(find.text('Como você está\nse sentindo hoje?'), findsOneWidget);
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
      expect(find.text('Resumo da semana'), findsOneWidget);
    });
  });
}
