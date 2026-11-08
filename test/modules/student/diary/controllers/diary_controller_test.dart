import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  group('DiaryController Tests', () {
    late LocalDiaryRepository repository;
    late DiaryController controller;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
      controller = DiaryController(repository: repository);
    });

    test('initial state satisfies Step 1 of RNF05 (interactionCount = 1)', () {
      expect(controller.selectedHumor, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isSaved, isFalse);
      expect(controller.feedbackMessage, isNull);
      expect(controller.entries, isEmpty);
      expect(controller.latestEntry, isNull);
      expect(controller.interactionCount, 1);
      expect(controller.isReadyToSave, isFalse);
    });

    test('selectHumor updates selection and interactionCount to 2', () {
      controller.selectHumor(Humor.feliz);

      expect(controller.selectedHumor, Humor.feliz);
      expect(controller.interactionCount, 2);
      expect(controller.isReadyToSave, isTrue);
      expect(controller.isSaved, isFalse);
    });

    test('saveHumor without selection returns false and does not persist', () async {
      final success = await controller.saveHumor();
      expect(success, isFalse);
      expect(controller.entries, isEmpty);
    });

    test('saveHumor persists entry and sets interactionCount to 3 (RNF05 fulfilled)', () async {
      controller.selectHumor(Humor.triste);
      expect(controller.interactionCount, 2);

      final success = await controller.saveHumor();

      expect(success, isTrue);
      expect(controller.isSaved, isTrue);
      expect(controller.interactionCount, 3);
      expect(controller.feedbackMessage, Humor.triste.comfortingMessage);
      expect(controller.entries.length, 1);
      expect(controller.latestEntry?.humor, Humor.triste);
      expect(controller.hasRecordedToday, isTrue);
    });

    test('resetSelection resets state for a new interaction cycle', () async {
      controller.selectHumor(Humor.ansioso);
      await controller.saveHumor();

      expect(controller.isSaved, isTrue);
      controller.resetSelection();

      expect(controller.selectedHumor, isNull);
      expect(controller.isSaved, isFalse);
      expect(controller.feedbackMessage, isNull);
      expect(controller.interactionCount, 1);
    });

    test('deleteEntry removes entry from repository and updates list', () async {
      controller.selectHumor(Humor.feliz);
      await controller.saveHumor();
      expect(controller.entries.length, 1);

      final id = controller.entries.first.id;
      await controller.deleteEntry(id);

      expect(controller.entries, isEmpty);
      expect(controller.latestEntry, isNull);
    });
  });
}
