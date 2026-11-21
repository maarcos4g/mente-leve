import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/home/mood_scale.dart';

final _now = DateTime(2026, 11, 20, 12);

RegistroDiario _reg(Humor humor, int diasAtras, [String? id]) => RegistroDiario(
  id: id ?? '$humor-$diasAtras',
  humor: humor,
  dataHora: _now.subtract(Duration(days: diasAtras)),
);

void main() {
  group('MoodScale', () {
    test('sem registros não tem nível', () {
      final scale = MoodScale.fromEntries([], _now);
      expect(scale.level, isNull);
      expect(scale.count, 0);
    });

    test('um registro devolve o score do humor', () {
      expect(MoodScale.fromEntries([_reg(Humor.feliz, 0)], _now).level, 5);
      expect(MoodScale.fromEntries([_reg(Humor.comRaiva, 1)], _now).level, 1);
      expect(MoodScale.fromEntries([_reg(Humor.ansioso, 2)], _now).level, 3);
    });

    test('média é arredondada', () {
      final scale = MoodScale.fromEntries(
        [_reg(Humor.feliz, 0), _reg(Humor.triste, 1), _reg(Humor.neutro, 2)],
        _now,
      ); // (5 + 2 + 4) / 3 = 3,67
      expect(scale.level, 4);
      expect(scale.count, 3);
    });

    test('ignora registros com mais de 7 dias', () {
      final scale = MoodScale.fromEntries(
        [_reg(Humor.feliz, 0), _reg(Humor.comRaiva, 8)],
        _now,
      );
      expect(scale.level, 5);
      expect(scale.count, 1);
    });

    test('só registros antigos resultam em sem nível', () {
      expect(MoodScale.fromEntries([_reg(Humor.feliz, 10)], _now).level, isNull);
    });
  });

  group('HomeController.weekMoods', () {
    test('sem registros nenhum cérebro é destacado', () async {
      final c = HomeController(repository: LocalDiaryRepository());
      await c.loadScale(now: _now);
      expect(c.weekMoods.every((m) => m.opacity < 1), isTrue);
    });

    test('destaca o cérebro do nível atual', () async {
      final repo = LocalDiaryRepository();
      await repo.save(_reg(Humor.neutro, 0));
      final c = HomeController(repository: repo);
      await c.loadScale(now: _now);

      final moods = c.weekMoods;
      expect(moods[3].opacity, 1);
      expect(moods[3].glowColor, HomeController.activeGlow);
      expect(moods.where((m) => m.opacity == 1).length, 1);
    });

    test('atualiza ao salvar novo humor', () async {
      final repo = LocalDiaryRepository();
      final c = HomeController(repository: repo);
      await repo.save(_reg(Humor.feliz, 0, 'a'));
      await c.loadScale(now: _now);
      expect(c.scale.level, 5);

      await repo.save(_reg(Humor.comRaiva, 1, 'b'));
      await c.loadScale(now: _now);
      expect(c.scale.level, 3); // (5 + 1) / 2
    });
  });
}
