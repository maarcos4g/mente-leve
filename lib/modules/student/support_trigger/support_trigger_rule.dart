import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';
import 'package:mente_leve/modules/student/support_trigger/models/support_trigger_state.dart';

/// Parâmetros do gatilho de apoio (RN11), reunidos em um só lugar.
///
/// Os valores padrão são uma proposta do grupo e precisam ser validados com
/// a psicóloga da escola. A regra é por categoria de humor, e não por nível,
/// porque o enum `Humor` não tem ordem.
class SupportTriggerConfig {
  const SupportTriggerConfig({
    this.negativeMoods = defaultNegativeMoods,
    this.consecutiveDays = defaultConsecutiveDays,
    this.moodAliases = defaultMoodAliases,
  }) : assert(consecutiveDays > 0);

  /// Humores que contam como dia negativo. `cansado` fica de fora por ser
  /// ambíguo; `feliz` e `neutro` não contam.
  static const defaultNegativeMoods = {'triste', 'ansioso', 'comRaiva'};

  /// Quantidade de dias seguidos negativos, incluindo hoje, para disparar.
  static const defaultConsecutiveDays = 3;

  /// Traduz outros nomes de humor para os nomes do enum `Humor`.
  ///
  /// A Home tem 5 imagens de humor (`assets/home/mood_*.svg`) e o enum tem 6
  /// valores. Se o registro de humor gravar o nome da imagem, ele passa por
  /// aqui. `confused` ficou sem mapeamento de propósito (não conta como
  /// negativo) até o grupo decidir a qual humor ele corresponde.
  static const defaultMoodAliases = {
    'happy': 'feliz',
    'neutral': 'neutro',
    'sad': 'triste',
    'angry': 'comRaiva',
  };

  final Set<String> negativeMoods;
  final int consecutiveDays;
  final Map<String, String> moodAliases;

  /// Humor fora do conjunto (ou desconhecido) não é negativo.
  bool isNegative(String mood) =>
      negativeMoods.contains(moodAliases[mood] ?? mood);
}

/// Decide se o modal de apoio deve aparecer. Lógica pura, sem Flutter, que
/// roda 100% no aparelho (RN02, RN11).
class SupportTriggerRule {
  const SupportTriggerRule([this.config = const SupportTriggerConfig()]);

  final SupportTriggerConfig config;

  /// Data local (meia-noite) de [moment], usando o fuso do aparelho.
  static DateTime dayOf(DateTime moment) {
    final local = moment.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime _addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  /// Primeiro instante cujos registros podem entrar na sequência de hoje.
  /// Serve para o repositório ler só o necessário.
  DateTime windowStart(DateTime now, SupportTriggerState state) {
    final firstDay = _addDays(dayOf(now), -(config.consecutiveDays - 1));
    final countFrom = state.countFrom;
    return countFrom != null && countFrom.isAfter(firstDay)
        ? countFrom
        : firstDay;
  }

  /// No máximo um modal por dia.
  bool wasShownToday(SupportTriggerState state, DateTime now) {
    final lastShownAt = state.lastShownAt;
    return lastShownAt != null && dayOf(lastShownAt) == dayOf(now);
  }

  /// `true` quando hoje e os dias anteriores necessários são negativos.
  ///
  /// Um dia é negativo se o último registro dele é de humor negativo. Um dia
  /// sem registro (ou com registros só antes de `countFrom`) quebra a
  /// sequência.
  bool shouldTrigger({
    required Iterable<MoodRecord> records,
    required SupportTriggerState state,
    required DateTime now,
  }) {
    if (wasShownToday(state, now)) return false;

    final start = windowStart(now, state);
    final lastOfDay = <DateTime, MoodRecord>{};
    for (final record in records) {
      if (record.dateTime.isBefore(start) || record.dateTime.isAfter(now)) {
        continue;
      }
      final day = dayOf(record.dateTime);
      final current = lastOfDay[day];
      if (current == null || record.dateTime.isAfter(current.dateTime)) {
        lastOfDay[day] = record;
      }
    }

    final today = dayOf(now);
    for (var i = 0; i < config.consecutiveDays; i++) {
      final record = lastOfDay[_addDays(today, -i)];
      if (record == null || !config.isNegative(record.mood)) return false;
    }
    return true;
  }

  /// Estado a gravar quando o modal aparece: a contagem recomeça no dia
  /// seguinte, então o modal não volta a cada novo registro.
  SupportTriggerState stateAfterShown(DateTime now) =>
      SupportTriggerState(lastShownAt: now, countFrom: _addDays(dayOf(now), 1));
}
