import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';
import 'package:mente_leve/modules/student/support_trigger/models/support_trigger_state.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_rule.dart';

/// "Agora" dos testes: 12/11/2026 às 20h, horário local.
final now = DateTime(2026, 11, 12, 20);

/// Registro [daysAgo] dias antes de [now], no horário [hour]:[minute].
MoodRecord record(String mood, int daysAgo, {int hour = 12, int minute = 0}) =>
    MoodRecord(
      mood: mood,
      dateTime: DateTime(now.year, now.month, now.day - daysAgo, hour, minute),
    );

void main() {
  const rule = SupportTriggerRule();

  bool check(
    List<MoodRecord> records, {
    SupportTriggerState state = SupportTriggerState.empty,
    DateTime? at,
  }) => rule.shouldTrigger(records: records, state: state, now: at ?? now);

  group('dispara', () {
    test('com 3 dias seguidos negativos, incluindo hoje', () {
      expect(
        check([
          record('triste', 2),
          record('ansioso', 1),
          record('comRaiva', 0),
        ]),
        isTrue,
      );
    });

    test('quando o último registro do dia é negativo', () {
      expect(
        check([
          record('triste', 2),
          record('feliz', 1, hour: 9),
          record('triste', 1, hour: 21),
          record('triste', 0),
        ]),
        isTrue,
      );
    });

    test('ignora dias anteriores à sequência', () {
      expect(
        check([
          record('feliz', 3),
          record('triste', 2),
          record('triste', 1),
          record('triste', 0),
        ]),
        isTrue,
      );
    });
  });

  group('não dispara', () {
    test('com histórico vazio', () {
      expect(check(const []), isFalse);
    });

    test('com histórico insuficiente (só 2 dias)', () {
      expect(check([record('triste', 1), record('triste', 0)]), isFalse);
    });

    test('quando um humor neutro interrompe a sequência', () {
      expect(
        check([record('triste', 2), record('neutro', 1), record('triste', 0)]),
        isFalse,
      );
    });

    test('quando um humor positivo interrompe a sequência', () {
      expect(
        check([record('feliz', 2), record('triste', 1), record('triste', 0)]),
        isFalse,
      );
    });

    test('quando o último registro do dia não é negativo', () {
      expect(
        check([
          record('triste', 2),
          record('triste', 1, hour: 9),
          record('feliz', 1, hour: 21),
          record('triste', 0),
        ]),
        isFalse,
      );
    });

    test('quando falta registro em um dia', () {
      expect(check([record('triste', 2), record('triste', 0)]), isFalse);
    });

    test('quando hoje não é negativo ou não tem registro', () {
      final previous = [
        record('triste', 3),
        record('triste', 2),
        record('triste', 1),
      ];
      expect(check(previous), isFalse);
      expect(check([...previous, record('neutro', 0)]), isFalse);
    });

    test('com humores fora do conjunto negativo (cansado)', () {
      expect(
        check([
          record('cansado', 2),
          record('cansado', 1),
          record('cansado', 0),
        ]),
        isFalse,
      );
    });

    test('com humor desconhecido', () {
      expect(
        check([record('triste', 2), record('outro', 1), record('triste', 0)]),
        isFalse,
      );
    });

    test('com registros no futuro (relógio do aparelho mudou)', () {
      expect(
        check([record('triste', 2), record('triste', 1), record('triste', -1)]),
        isFalse,
      );
    });
  });

  group('virada de dia', () {
    test('23h59 e 0h01 contam como dias diferentes', () {
      final justAfterMidnight = DateTime(2026, 11, 12, 0, 5);
      expect(
        check([
          record('triste', 2),
          record('triste', 1, hour: 23, minute: 59),
          record('triste', 0, hour: 0, minute: 1),
        ], at: justAfterMidnight),
        isTrue,
      );
    });

    test('dois registros no mesmo dia contam como um dia só', () {
      expect(
        check([
          record('triste', 1, hour: 0, minute: 1),
          record('triste', 1, hour: 23, minute: 59),
          record('triste', 0),
        ]),
        isFalse,
      );
    });

    test('a sequência atravessa a virada do mês', () {
      final firstOfMonth = DateTime(2026, 12, 1, 10);
      expect(
        check([
          MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 29, 18)),
          MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 30, 18)),
          MoodRecord(mood: 'triste', dateTime: DateTime(2026, 12, 1, 9)),
        ], at: firstOfMonth),
        isTrue,
      );
    });
  });

  group('frequência', () {
    final negativeStreak = [
      record('triste', 2),
      record('triste', 1),
      record('triste', 0),
    ];

    test('no máximo um modal por dia', () {
      final shownToday = SupportTriggerState(
        lastShownAt: DateTime(2026, 11, 12, 8),
      );
      expect(rule.wasShownToday(shownToday, now), isTrue);
      expect(check(negativeStreak, state: shownToday), isFalse);
    });

    test('ao exibir, a contagem recomeça no dia seguinte', () {
      final state = rule.stateAfterShown(now);
      expect(state.lastShownAt, now);
      expect(state.countFrom, DateTime(2026, 11, 13));
    });

    test('depois de exibir, só volta após nova sequência completa', () {
      final shownAt = DateTime(2026, 11, 12, 20);
      final state = rule.stateAfterShown(shownAt);
      final history = [
        ...negativeStreak,
        MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 12, 22)),
        MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 13, 9)),
        MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 14, 9)),
      ];

      // Mesmo dia e os dois dias seguintes: a sequência antiga não conta.
      expect(
        check(history, state: state, at: DateTime(2026, 11, 12, 23)),
        isFalse,
      );
      expect(
        check(history, state: state, at: DateTime(2026, 11, 13, 10)),
        isFalse,
      );
      expect(
        check(history, state: state, at: DateTime(2026, 11, 14, 10)),
        isFalse,
      );

      // Terceiro dia negativo depois do reinício: dispara de novo.
      final later = [
        ...history,
        MoodRecord(mood: 'ansioso', dateTime: DateTime(2026, 11, 15, 9)),
      ];
      expect(
        check(later, state: state, at: DateTime(2026, 11, 15, 10)),
        isTrue,
      );
    });

    test('windowStart usa countFrom quando ele é mais recente', () {
      final state = SupportTriggerState(countFrom: DateTime(2026, 11, 12));
      expect(rule.windowStart(now, state), DateTime(2026, 11, 12));
      expect(
        rule.windowStart(now, SupportTriggerState.empty),
        DateTime(2026, 11, 10),
      );
    });
  });

  group('configuração', () {
    test('conjunto negativo padrão', () {
      const config = SupportTriggerConfig();
      expect(config.isNegative('triste'), isTrue);
      expect(config.isNegative('ansioso'), isTrue);
      expect(config.isNegative('comRaiva'), isTrue);
      expect(config.isNegative('cansado'), isFalse);
      expect(config.isNegative('feliz'), isFalse);
      expect(config.isNegative('neutro'), isFalse);
    });

    test('nomes das imagens da Home passam pelo mapeamento', () {
      const config = SupportTriggerConfig();
      expect(config.isNegative('sad'), isTrue);
      expect(config.isNegative('angry'), isTrue);
      expect(config.isNegative('happy'), isFalse);
      expect(config.isNegative('neutral'), isFalse);
      // Sem mapeamento definido: não conta como negativo.
      expect(config.isNegative('confused'), isFalse);
    });

    test('parâmetros podem ser trocados em um só lugar', () {
      const custom = SupportTriggerRule(
        SupportTriggerConfig(
          negativeMoods: {'triste', 'cansado'},
          consecutiveDays: 2,
          moodAliases: {'confused': 'ansioso'},
        ),
      );
      expect(
        custom.shouldTrigger(
          records: [record('cansado', 1), record('triste', 0)],
          state: SupportTriggerState.empty,
          now: now,
        ),
        isTrue,
      );
      expect(custom.config.isNegative('confused'), isFalse);
    });
  });
}
