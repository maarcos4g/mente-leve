import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/diary/widgets/recent_moods_summary.dart';

void main() {
  group('RecentMoodsSummary Widget Tests', () {
    late LocalDiaryRepository repository;
    late DiaryController controller;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
      controller = DiaryController(repository: repository);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RecentMoodsSummary(controller: controller),
          ),
        ),
      );
    }

    testWidgets('renders empty state when no entries recorded', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Resumo da semana'), findsOneWidget);
      expect(find.text('Nenhum registro ainda'), findsOneWidget);
      expect(find.text('Toque em um emoji acima para registrar como você está se sentindo hoje.'), findsOneWidget);
    });

    testWidgets('renders list of entries when entries exist', (tester) async {
      controller.selectHumor(Humor.feliz);
      await controller.saveHumor();

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Resumo da semana'), findsOneWidget);
      expect(find.text('1 registro'), findsOneWidget);
      expect(find.text('Feliz'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
    });
  });
}
