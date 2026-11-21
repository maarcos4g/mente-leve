import 'dart:convert';

import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistência definitiva do diário no aparelho (RNF02, RNF03).
///
/// Usa o mesmo `SharedPreferences` do perfil do aluno (`ProfileStore`). Os
/// registros ficam na chave `diario` como um JSON `{id: registro}`; nada vai
/// para a nuvem, então ler e escrever funciona sem internet.
///
/// Dado corrompido não derruba o diário: um registro inválido é ignorado na
/// leitura, e se a chave inteira estiver ilegível o texto original vai para
/// [corruptedKey] (para não se perder) e o diário recomeça vazio.
class PrefsDiaryRepository implements DiaryRepository {
  PrefsDiaryRepository(this._prefs);

  static const storageKey = 'diario';

  /// Cópia do conteúdo de [storageKey] quando ele não pôde ser lido.
  static const corruptedKey = 'diario_corrompido';

  final SharedPreferences _prefs;

  Future<Map<String, dynamic>> _read() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return {};

    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      await _prefs.setString(corruptedKey, raw);
      await _prefs.remove(storageKey);
      return {};
    }
  }

  Future<void> _write(Map<String, dynamic> data) =>
      _prefs.setString(storageKey, jsonEncode(data));

  @override
  Future<void> save(RegistroDiario registro) async {
    final data = await _read();
    data[registro.id] = registro.toMap();
    await _write(data);
  }

  @override
  Future<List<RegistroDiario>> getAll() async {
    final list = <RegistroDiario>[];
    for (final value in (await _read()).values) {
      final registro = _parse(value);
      if (registro != null) list.add(registro);
    }
    list.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return List.unmodifiable(list);
  }

  /// Registro em formato inesperado vira `null` e é ignorado.
  static RegistroDiario? _parse(Object? value) {
    if (value is! Map) return null;
    try {
      return RegistroDiario.fromMap(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RegistroDiario?> getLatest() async {
    final list = await getAll();
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<void> delete(String id) async {
    final data = await _read();
    if (data.remove(id) != null) await _write(data);
  }

  @override
  Future<void> clear() => _prefs.remove(storageKey);
}
