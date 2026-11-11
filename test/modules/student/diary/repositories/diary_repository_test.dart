import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  group('LocalDiaryRepository Tests', () {
    late LocalDiaryRepository repository;

    setUp(() async {
      repository = LocalDiaryRepository.instance;
      await repository.clear();
    });

    test('starts empty', () async {
      expect(await repository.getAll(), isEmpty);
      expect(await repository.getLatest(), isNull);
      expect(repository.count, 0);
    });

    test('saves and retrieves entries sorted newest first', () async {
      final older = RegistroDiario(
        id: '1',
        humor: Humor.triste,
        dataHora: DateTime(2026, 11, 7, 10, 0),
      );
      final newer = RegistroDiario(
        id: '2',
        humor: Humor.feliz,
        dataHora: DateTime(2026, 11, 8, 14, 0),
      );

      await repository.save(older);
      await repository.save(newer);

      final list = await repository.getAll();
      expect(list.length, 2);
      expect(list[0].id, '2'); // Mais recente primeiro
      expect(list[1].id, '1');

      final latest = await repository.getLatest();
      expect(latest?.id, '2');
    });

    test('deletes an entry by id', () async {
      final reg = RegistroDiario(
        id: '123',
        humor: Humor.ansioso,
        dataHora: DateTime.now(),
      );

      await repository.save(reg);
      expect(repository.count, 1);

      await repository.delete('123');
      expect(repository.count, 0);
      expect(await repository.getAll(), isEmpty);
    });

    test('clear removes all entries', () async {
      await repository.save(RegistroDiario(
        id: '1',
        humor: Humor.neutro,
        dataHora: DateTime.now(),
      ));
      await repository.save(RegistroDiario(
        id: '2',
        humor: Humor.cansado,
        dataHora: DateTime.now(),
      ));

      expect(repository.count, 2);
      await repository.clear();
      expect(repository.count, 0);
    });
  });
}
