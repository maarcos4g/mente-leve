import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/hive_diary_repository.dart';

/// Testa a gravação real em disco, com a caixa criptografada.
/// A chave aqui é gerada no teste; no app ela vem do armazenamento seguro.
void main() {
  late Directory dir;
  late List<int> key;

  Future<HiveDiaryRepository> openRepository() async {
    final box = await Hive.openBox<Map>(
      HiveDiaryRepository.boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    return HiveDiaryRepository(box);
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('diario_test');
    Hive.init(dir.path);
    key = Hive.generateSecureKey();
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  final registro = RegistroDiario(
    id: '1',
    humor: Humor.feliz,
    texto: 'Hoje foi um dia bom',
    pontosPositivos: const ['Dormi bem', 'Ajudei alguém'],
    dataHora: DateTime(2026, 11, 9, 20, 30),
  );

  test('mantém o registro depois de fechar e reabrir o app', () async {
    await (await openRepository()).save(registro);
    await Hive.close();

    final reaberto = await openRepository();
    expect(await reaberto.getAll(), [registro]);
  });

  test('os dados ficam criptografados no arquivo', () async {
    await (await openRepository()).save(registro);
    await Hive.close();

    final file = File('${dir.path}/${HiveDiaryRepository.boxName}.hive');
    final bytes = await file.readAsBytes();
    final conteudo = String.fromCharCodes(bytes);

    expect(conteudo.contains('Hoje foi um dia bom'), isFalse);
    expect(conteudo.contains('Dormi bem'), isFalse);
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
