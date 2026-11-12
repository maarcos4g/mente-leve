import 'package:mente_leve/modules/student/support_trigger/repositories/mood_record_repository.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/support_trigger_state_store.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_rule.dart';

/// Liga a regra do gatilho (RN11) ao histórico e ao estado guardados no
/// aparelho. Roda offline e não registra quem recebeu o modal (RN01, RN08).
///
/// Qualquer falha de leitura faz o gatilho não disparar: o registro do humor
/// já foi salvo e o aluno nunca fica bloqueado.
class SupportTriggerController {
  SupportTriggerController({
    required this.records,
    required this.stateStore,
    this.rule = const SupportTriggerRule(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final MoodRecordRepository records;
  final SupportTriggerStateStore stateStore;
  final SupportTriggerRule rule;
  final DateTime Function() _clock;

  /// Chamado logo depois que o humor é salvo.
  Future<bool> shouldShowAfterMoodSaved() async {
    try {
      final now = _clock();
      final state = stateStore.read();
      if (rule.wasShownToday(state, now)) return false;

      final history = await records.recordsSince(rule.windowStart(now, state));
      return rule.shouldTrigger(records: history, state: state, now: now);
    } catch (_) {
      return false;
    }
  }

  /// Grava `lastShownAt` e `countFrom` ao exibir o modal. Se a gravação
  /// falhar, o modal ainda aparece; no pior caso ele volta no próximo
  /// registro do mesmo dia.
  Future<void> markShown() async {
    try {
      await stateStore.save(rule.stateAfterShown(_clock()));
    } catch (_) {}
  }
}
