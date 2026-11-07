import 'dart:convert';

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

  Future<void> clear() => _store.remove(_key);
}
