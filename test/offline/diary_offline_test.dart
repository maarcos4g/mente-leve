import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/repositories/prefs_diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bateria offline (EPIC-09): o diário só usa o armazenamento do aparelho,
/// então registrar e ler funciona igual com ou sem internet. Nada fica
/// pendente de sincronização, porque o diário nunca vai para a nuvem (RNF03).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<DiaryController> abrirDiario() async => DiaryController(
    repository: PrefsDiaryRepository(await SharedPreferences.getInstance()),
    agora: () => DateTime(2026, 11, 21, 18),
  );

  test('registra o humor e continua lá depois de reabrir o app', () async {
    final diario = await abrirDiario();
    diario.selectHumor(Humor.feliz);
    await diario.saveHumor().timeout(const Duration(seconds: 1));

    final reaberto = await abrirDiario();
    await reaberto.loadEntries();

    expect(reaberto.entries.single.humor, Humor.feliz);
    expect(reaberto.hasRecordedToday, isTrue);
  });

  test('um segundo registro no mesmo dia altera o humor do dia', () async {
    final diario = await abrirDiario();
    diario.selectHumor(Humor.triste);
    await diario.saveHumor();
    diario.selectHumor(Humor.neutro);
    await diario.saveHumor();

    final reaberto = await abrirDiario();
    await reaberto.loadEntries();

    expect(reaberto.entries.single.humor, Humor.neutro);
  });
}
