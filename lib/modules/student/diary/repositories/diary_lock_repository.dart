import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o PIN que protege o Diário Pessoal.
///
/// O PIN fica só no aparelho (RNF02, RNF03): nada vai para a nuvem.
abstract class DiaryLockRepository {
  /// Tamanho do PIN (só números).
  static const pinLength = 4;

  static final _pinRegex = RegExp(r'^\d{4}$');

  /// Indica se [pin] tem exatamente [pinLength] números.
  static bool isValidPin(String pin) => _pinRegex.hasMatch(pin);

  /// Indica se o diário tem PIN cadastrado.
  Future<bool> hasPin();

  /// Confere [pin] com o PIN cadastrado. Sem PIN cadastrado, retorna `false`.
  Future<bool> verify(String pin);

  /// Cadastra ou troca o PIN.
  Future<void> setPin(String pin);

  /// Remove o PIN (o diário deixa de pedir senha).
  Future<void> removePin();
}

/// Implementação em memória, usada por padrão e nos testes.
class LocalDiaryLockRepository implements DiaryLockRepository {
  LocalDiaryLockRepository([this._pin]);

  static final LocalDiaryLockRepository instance = LocalDiaryLockRepository();

  String? _pin;

  @override
  Future<bool> hasPin() async => _pin != null;

  @override
  Future<bool> verify(String pin) async => _pin != null && _pin == pin;

  @override
  Future<void> setPin(String pin) async => _pin = pin;

  @override
  Future<void> removePin() async => _pin = null;
}

/// Persistência do PIN no `SharedPreferences` do aparelho.
///
/// O PIN não é salvo em texto puro: a chave `diario_pin` guarda um JSON
/// `{salt, hash}` com o SHA-256 de `salt + pin`.
class PrefsDiaryLockRepository implements DiaryLockRepository {
  PrefsDiaryLockRepository(this._prefs, {Random? random})
      : _random = random ?? Random.secure();

  static const storageKey = 'diario_pin';

  final SharedPreferences _prefs;
  final Random _random;

  static String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt$pin')).toString();

  /// Lê `{salt, hash}`; dado ausente ou corrompido conta como sem PIN, para
  /// o aluno nunca ficar trancado fora do próprio diário.
  ({String salt, String hash})? _read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      final salt = data['salt'];
      final hash = data['hash'];
      if (salt is! String || hash is! String) return null;
      return (salt: salt, hash: hash);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<bool> hasPin() async => _read() != null;

  @override
  Future<bool> verify(String pin) async {
    final data = _read();
    return data != null && _hash(data.salt, pin) == data.hash;
  }

  @override
  Future<void> setPin(String pin) async {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    final salt = base64Url.encode(bytes);
    await _prefs.setString(
      storageKey,
      jsonEncode({'salt': salt, 'hash': _hash(salt, pin)}),
    );
  }

  @override
  Future<void> removePin() => _prefs.remove(storageKey);
}
