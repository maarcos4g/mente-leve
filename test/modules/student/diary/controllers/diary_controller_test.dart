import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
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

    test('concurrent saveHumor calls are guarded against reentrancy', () async {
      controller.selectHumor(Humor.cansado);

      // Launch two saves concurrently
      final f1 = controller.saveHumor();
      final f2 = controller.saveHumor();

      final results = await Future.wait([f1, f2]);

      // Exactly one save must succeed and exactly one entry must be stored
      expect(results, contains(true));
      expect(results, contains(false));
      expect(controller.entries.length, 1);
    });

    test('hasRecordedToday accurately identifies today entry even if older entries exist', () async {
      final olderDate = DateTime.now().subtract(const Duration(days: 3));
      await repository.save(RegistroDiario(
        id: 'old_1',
        humor: Humor.triste,
        dataHora: olderDate,
      ));

      await controller.loadEntries();
      expect(controller.hasRecordedToday, isFalse);

      controller.selectHumor(Humor.feliz);
      await controller.saveHumor();
      expect(controller.hasRecordedToday, isTrue);
    });
      group('Um sentimento por dia', () {
      test('salvar de novo no mesmo dia altera o humor sem criar outro registro', () async {
        controller.selectHumor(Humor.triste);
        await controller.saveHumor();
        final id = controller.entries.single.id;
        expect(controller.lastSaveUpdated, isFalse);

        controller.selectHumor(Humor.feliz);
        final success = await controller.saveHumor();

        expect(success, isTrue);
        expect(controller.lastSaveUpdated, isTrue);
        expect(controller.entries.length, 1);
        expect(controller.entries.single.id, id);
        expect(controller.registroDeHoje?.humor, Humor.feliz);
      });

      test('alterar o humor mantém o texto e os pontos positivos do dia', () async {
        await repository.save(RegistroDiario(
          id: 'hoje',
          humor: Humor.neutro,
          texto: 'Dia de prova',
          pontosPositivos: const ['Dormi bem'],
          dataHora: DateTime.now(),
        ));

        controller.selectHumor(Humor.ansioso);
        await controller.saveHumor();

        final registro = controller.entries.single;
        expect(registro.id, 'hoje');
        expect(registro.humor, Humor.ansioso);
        expect(registro.texto, 'Dia de prova');
        expect(registro.pontosPositivos, ['Dormi bem']);
      });

      test('reconhece o registro de hoje mesmo sem loadEntries antes', () async {
        await repository.save(RegistroDiario(
          id: 'hoje',
          humor: Humor.neutro,
          dataHora: DateTime.now(),
        ));

        controller.selectHumor(Humor.feliz);
        await controller.saveHumor();

        expect(controller.entries.length, 1);
        expect(controller.entries.single.humor, Humor.feliz);
      });

      test('registro de ontem não é alterado; hoje ganha um registro novo', () async {
        final agora = DateTime(2026, 11, 16, 10);
        controller = DiaryController(repository: repository, agora: () => agora);
        await repository.save(RegistroDiario(
          id: 'ontem',
          humor: Humor.triste,
          dataHora: DateTime(2026, 11, 15, 22),
        ));

        controller.selectHumor(Humor.feliz);
        await controller.saveHumor();

        expect(controller.entries.length, 2);
        expect(controller.lastSaveUpdated, isFalse);
        expect(controller.entries.firstWhere((e) => e.id == 'ontem').humor,
            Humor.triste);
      });
    });
  });
}
