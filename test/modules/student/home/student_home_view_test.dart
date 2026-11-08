import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/home/student_home_view.dart';

void main() {
  group('StudentHomeView Widget Tests', () {
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

    testWidgets('renders student greeting, mood card, and bottom tabs', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(nickname: 'Lucas'));

      expect(find.text('Olá, Lucas!'), findsOneWidget);
      expect(find.text('Seu porto seguro, direto no bolso'), findsOneWidget);
      expect(find.text('Como está sua mente hoje?'), findsOneWidget);
      expect(find.text('Resumo da semana'), findsOneWidget);
      expect(find.text('Ajuda (CVV)'), findsOneWidget);

      // Verify bottom navigation bar items
      expect(find.text('Diário'), findsOneWidget);
      expect(find.text('Escrever'), findsOneWidget);
      expect(find.text('Ajuda/FAQ'), findsOneWidget);
      expect(find.text('Canais'), findsOneWidget);
    });

    testWidgets('tapping Ajuda (CVV) opens emergency dialog', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Ajuda (CVV)'));
      await tester.pumpAndSettle();

      expect(find.text('CVV 188 — Centro de Valorização da Vida'), findsOneWidget);
      expect(find.text('Ligar 188 agora'), findsOneWidget);
    });

    testWidgets('mascot advice reacts dynamically when student registers mood', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Baseline mascot tip
      expect(
        find.text('Registrar o que você sente ajuda a clarear os pensamentos. Pegue leve com você hoje!'),
        findsOneWidget,
      );

      // Select and save Feliz
      await tester.tap(find.text('Feliz'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Feliz'));
      await tester.pumpAndSettle();

      // Mascot advice dynamically updates to comforting message
      expect(
        find.text('Que bom te ver bem! Aproveite cada momento leve do seu dia.'),
        findsWidgets, // present in feedback banner and mascot tip
      );
    });
  });
}
