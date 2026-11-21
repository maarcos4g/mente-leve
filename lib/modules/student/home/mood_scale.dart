import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';

/// Escala de 1 a 5 que resume os humores registrados na última semana.
///
/// Na Home, cada nível corresponde a um dos cinco cérebros, do pior (1) ao
/// melhor (5): raiva, triste, confuso (ansioso), neutro e feliz.
class MoodScale {
  const MoodScale._(this.level, this.average, this.count);

  static const minLevel = 1;
  static const maxLevel = 5;

  /// Janela considerada no resumo.
  static const window = Duration(days: 7);

  /// Nível arredondado (1 a 5) ou `null` quando não há registros na semana.
  final int? level;

  /// Média não arredondada dos scores, ou `null` sem registros.
  final double? average;

  /// Quantidade de registros considerados.
  final int count;

  static const empty = MoodScale._(null, null, 0);

  /// Pontuação de cada humor na escala. `cansado` não tem cérebro próprio e
  /// conta como nível 2, próximo de triste.
  static int scoreOf(Humor humor) => switch (humor) {
    Humor.comRaiva => 1,
    Humor.triste => 2,
    Humor.cansado => 2,
    Humor.ansioso => 3,
    Humor.neutro => 4,
    Humor.feliz => 5,
  };

  /// Calcula a escala com os registros dos últimos 7 dias até [now].
  factory MoodScale.fromEntries(List<RegistroDiario> entries, DateTime now) {
    final start = now.subtract(window);
    final recent = entries
        .where((e) => e.dataHora.isAfter(start) && !e.dataHora.isAfter(now))
        .toList();
    if (recent.isEmpty) return empty;

    final total = recent.fold<int>(0, (sum, e) => sum + scoreOf(e.humor));
    final average = total / recent.length;
    final level = average.round().clamp(minLevel, maxLevel);
    return MoodScale._(level, average, recent.length);
  }
}
