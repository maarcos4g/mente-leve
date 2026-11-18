import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/prefs_diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<PrefsDiaryRepository> openRepository() async =>
      PrefsDiaryRepository(await SharedPreferences.getInstance());

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final registro = RegistroDiario(
    id: '1',
    humor: Humor.feliz,
    texto: 'Hoje foi um dia bom',
    pontosPositivos: const ['Dormi bem', 'Ajudei alguém'],
    dataHora: DateTime(2026, 11, 9, 20, 30),
  );

  test('começa vazio', () async {
    final repo = await openRepository();
    expect(await repo.getAll(), isEmpty);
    expect(await repo.getLatest(), isNull);
  });

  test('mantém o registro em outra instância (app reaberto)', () async {
    await (await openRepository()).save(registro);

    final reaberto = await openRepository();
    expect(await reaberto.getAll(), [registro]);
  });

  test('ordena do mais recente ao mais antigo, atualiza e exclui', () async {
    final repo = await openRepository();
    final antigo = registro.copyWith(id: '0', dataHora: DateTime(2026, 11, 1));
    await repo.save(antigo);
    await repo.save(registro);

    expect((await repo.getAll()).map((r) => r.id), ['1', '0']);
    expect((await repo.getLatest())!.id, '1');

    await repo.save(registro.editar(texto: 'Editado'));
    expect((await repo.getLatest())!.texto, 'Editado');
    expect(await repo.getAll(), hasLength(2));

    await repo.delete('1');
    expect((await repo.getAll()).single.id, '0');

    await repo.clear();
    expect(await repo.getLatest(), isNull);
  });
}
