import 'dart:convert';
import 'dart:math';

import 'package:mente_leve/shared/models/local_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore {
  final SharedPreferences _store;

  ProfileStore(this._store);

  static const _key = 'profile';

  LocalUserModel? read() {
    final raw = _store.getString(_key);
    if (raw == null) return null;

    try {
      return LocalUserModel.fromMap(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(LocalUserModel profile) =>
      _store.setString(_key, jsonEncode(profile.toMap()));

  /// Id do aluno quando ele entra sem internet (RNF02).
  ///
  /// É gerado uma vez e fica guardado no aparelho, então a sessão offline
  /// mantém o mesmo id até o aluno sair. Começa com `local-` para não ser
  /// confundido com um uid do Firebase.
  Future<String> localUid() async {
    final saved = _store.getString(_localUidKey);
    if (saved != null) return saved;

    final random = Random.secure();
    final hex = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final uid = 'local-$hex';
    await _store.setString(_localUidKey, uid);
    return uid;
  }

  Future<void> clear() async {
    await _store.remove(_key);
    await _store.remove(_localUidKey);
  }

  static const _localUidKey = 'profile_local_uid';
}
