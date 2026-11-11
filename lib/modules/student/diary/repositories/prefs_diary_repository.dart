import 'dart:convert';

import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistência definitiva do diário no aparelho (RNF02, RNF03).
///
/// Usa o mesmo `SharedPreferences` do perfil do aluno (`ProfileStore`). Os
/// registros ficam na chave `diario` como um JSON `{id: registro}`; nada vai
/// para a nuvem.
class PrefsDiaryRepository implements DiaryRepository {
  PrefsDiaryRepository(this._prefs);

  static const storageKey = 'diario';

  final SharedPreferences _prefs;

  Map<String, dynamic> _read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _write(Map<String, dynamic> data) =>
      _prefs.setString(storageKey, jsonEncode(data));

  @override
  Future<void> save(RegistroDiario registro) async {
    final data = _read();
    data[registro.id] = registro.toMap();
    await _write(data);
  }

  @override
  Future<List<RegistroDiario>> getAll() async {
    final list = _read()
        .values
        .map((value) => RegistroDiario.fromMap(value as Map))
        .toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return List.unmodifiable(list);
  }

  @override
  Future<RegistroDiario?> getLatest() async {
    final list = await getAll();
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<void> delete(String id) async {
    final data = _read();
    if (data.remove(id) != null) await _write(data);
  }

  @override
  Future<void> clear() => _prefs.remove(storageKey);
}
