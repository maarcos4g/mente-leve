import 'dart:convert';

import 'package:mente_leve/modules/student/support_trigger/models/support_trigger_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o estado de controle do gatilho no aparelho, no mesmo
/// `SharedPreferences` do diário e do perfil (RN02). Nada vai para a nuvem.
class SupportTriggerStateStore {
  SupportTriggerStateStore(this._store);

  final SharedPreferences _store;

  static const storageKey = 'support_trigger_state';

  /// Estado salvo, ou vazio se não houver nada ou se estiver corrompido.
  SupportTriggerState read() {
    final raw = _store.getString(storageKey);
    if (raw == null) return SupportTriggerState.empty;

    try {
      return SupportTriggerState.fromMap(jsonDecode(raw) as Map);
    } catch (_) {
      return SupportTriggerState.empty;
    }
  }

  Future<void> save(SupportTriggerState state) =>
      _store.setString(storageKey, jsonEncode(state.toMap()));

  Future<void> clear() => _store.remove(storageKey);
}
