import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  group('Edge Cases and Boundary Tests', () {
    late LocalDiaryRepository repository;
    late DiaryController controller;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
      controller = DiaryController(repository: repository);
    });

    test('RegistroDiario.fromMap handles missing or null optional fields safely', () {
      final mapWithNulls = {
        'id': 'abc',
        'humor': 'neutro',
        'texto': null,
        'pontosPositivos': null,
        'dataHora': '2026-11-08T10:00:00.000',
      };

      final registro = RegistroDiario.fromMap(mapWithNulls);
      expect(registro.id, 'abc');
      expect(registro.humor, Humor.neutro);
      expect(registro.texto, isNull);
      expect(registro.pontosPositivos, isEmpty);
      expect(registro.temTexto, isFalse);
    });

    test('RegistroDiario.fromMap throws ArgumentError on unknown humor name', () {
      final invalidMap = {
        'id': 'xyz',
        'humor': 'inexistente',
        'dataHora': '2026-11-08T10:00:00.000',
      };

      expect(() => RegistroDiario.fromMap(invalidMap), throwsArgumentError);
    });

    test('Rapid consecutive mood selections update selection without multiple increments', () {
      expect(controller.interactionCount, 1);

      controller.selectHumor(Humor.feliz);
      expect(controller.selectedHumor, Humor.feliz);
      expect(controller.interactionCount, 2);

      controller.selectHumor(Humor.cansado);
      expect(controller.selectedHumor, Humor.cansado);
      expect(controller.interactionCount, 2);

      controller.selectHumor(Humor.ansioso);
      expect(controller.selectedHumor, Humor.ansioso);
      expect(controller.interactionCount, 2);
    });

    test('Selecting the same humor repeatedly does not emit unnecessary state changes', () {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.selectHumor(Humor.feliz);
      expect(notifyCount, 1);

      controller.selectHumor(Humor.feliz); // Identical selection
      expect(notifyCount, 1); // Not duplicated
    });

    test('Multiple entries on different dates maintain chronological order', () async {
      final t1 = DateTime(2026, 11, 1, 8, 0);
      final t2 = DateTime(2026, 11, 5, 12, 0);
      final t3 = DateTime(2026, 11, 8, 16, 0);

      await repository.save(RegistroDiario(id: '1', humor: Humor.triste, dataHora: t1));
      await repository.save(RegistroDiario(id: '3', humor: Humor.feliz, dataHora: t3));
      await repository.save(RegistroDiario(id: '2', humor: Humor.neutro, dataHora: t2));

      final all = await repository.getAll();
      expect(all.map((e) => e.id).toList(), ['3', '2', '1']);
      expect((await repository.getLatest())?.id, '3');
    });

    test('Updating an existing record with same ID performs upsert', () async {
      final initial = RegistroDiario(
        id: 'dup_id',
        humor: Humor.triste,
        dataHora: DateTime.now(),
      );
      final updated = RegistroDiario(
        id: 'dup_id',
        humor: Humor.feliz,
        dataHora: DateTime.now(),
      );

      await repository.save(initial);
      expect(repository.count, 1);
      expect((await repository.getLatest())?.humor, Humor.triste);

      await repository.save(updated);
      expect(repository.count, 1);
      expect((await repository.getLatest())?.humor, Humor.feliz);
    });

    test('Deleting non-existent ID does not throw or corrupt state', () async {
      await repository.save(RegistroDiario(
        id: 'real_id',
        humor: Humor.neutro,
        dataHora: DateTime.now(),
      ));

      await repository.delete('ghost_id');
      expect(repository.count, 1);
    });

    test('hasRecordedToday accurately checks current day vs older days', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await repository.save(RegistroDiario(
        id: 'old',
        humor: Humor.cansado,
        dataHora: yesterday,
      ));

      await controller.loadEntries();
      expect(controller.hasRecordedToday, isFalse);

      controller.selectHumor(Humor.feliz);
      await controller.saveHumor();
      expect(controller.hasRecordedToday, isTrue);
    });
  });
}
