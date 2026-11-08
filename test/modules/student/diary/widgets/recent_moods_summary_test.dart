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

    group('formatDateTime tests', () {
      test('formats today correctly', () {
        final now = DateTime(2026, 11, 8, 15, 30);
        final entry = DateTime(2026, 11, 8, 10, 5);

        expect(
          RecentMoodsSummary.formatDateTime(entry, now: now),
          'Hoje às 10:05',
        );
      });

      test('formats yesterday within same month correctly', () {
        final now = DateTime(2026, 11, 8, 15, 30);
        final entry = DateTime(2026, 11, 7, 20, 45);

        expect(
          RecentMoodsSummary.formatDateTime(entry, now: now),
          'Ontem às 20:45',
        );
      });

      test('formats yesterday across month boundary correctly', () {
        final now = DateTime(2026, 11, 1, 9, 0); // Nov 1st
        final entry = DateTime(2026, 10, 31, 22, 15); // Oct 31st

        expect(
          RecentMoodsSummary.formatDateTime(entry, now: now),
          'Ontem às 22:15',
        );
      });

      test('formats yesterday across year boundary correctly', () {
        final now = DateTime(2027, 1, 1, 8, 0); // Jan 1st 2027
        final entry = DateTime(2026, 12, 31, 23, 30); // Dec 31st 2026

        expect(
          RecentMoodsSummary.formatDateTime(entry, now: now),
          'Ontem às 23:30',
        );
      });

      test('formats older dates with dd/MM format', () {
        final now = DateTime(2026, 11, 8, 15, 0);
        final entry = DateTime(2026, 11, 2, 14, 20);

        expect(
          RecentMoodsSummary.formatDateTime(entry, now: now),
          '02/11 às 14:20',
        );
      });
    });
  });
}
