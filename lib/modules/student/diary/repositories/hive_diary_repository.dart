import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

/// Persistência definitiva do diário no aparelho (RNF02, RNF03, RN02).
///
/// Os registros ficam na caixa `diario` do Hive, criptografada com AES-256.
/// A chave é gerada no primeiro uso e guardada no armazenamento seguro do
/// sistema (Keystore no Android), nunca no código nem na nuvem.
class HiveDiaryRepository implements DiaryRepository {
  HiveDiaryRepository(this._box);

  static const boxName = 'diario';
  static const _encryptionKeyName = 'diario_chave_criptografia';

  final Box<Map> _box;

  /// Inicializa o Hive, recupera (ou cria) a chave e abre a caixa criptografada.
  static Future<HiveDiaryRepository> open({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) async {
    await Hive.initFlutter();
    final key = await _loadOrCreateKey(secureStorage);
    final box = await Hive.openBox<Map>(
      boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    return HiveDiaryRepository(box);
  }

  static Future<List<int>> _loadOrCreateKey(FlutterSecureStorage storage) async {
    final saved = await storage.read(key: _encryptionKeyName);
    if (saved != null) return base64Url.decode(saved);

    final key = Hive.generateSecureKey();
    await storage.write(key: _encryptionKeyName, value: base64UrlEncode(key));
    return key;
  }

  @override
  Future<void> save(RegistroDiario registro) =>
      _box.put(registro.id, registro.toMap());

  @override
  Future<List<RegistroDiario>> getAll() async {
    final list = _box.values.map(RegistroDiario.fromMap).toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return List.unmodifiable(list);
  }

  @override
  Future<RegistroDiario?> getLatest() async {
    final list = await getAll();
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Future<void> clear() => _box.clear();
}
