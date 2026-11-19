import 'package:flutter/foundation.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_lock_repository.dart';

/// Controla a proteção por PIN do Diário Pessoal (cadeado da App Bar).
///
/// Com PIN cadastrado, a tela só mostra o diário depois de [unlock]. O PIN
/// fica só no aparelho, então tudo funciona offline.
class DiaryLockController extends ChangeNotifier {
  DiaryLockController({DiaryLockRepository? repository})
      : repository = repository ?? defaultRepository;

  /// Repositório usado quando nenhum é injetado. O `main.dart` troca pelo
  /// `PrefsDiaryLockRepository` na inicialização; nos testes fica o de memória.
  static DiaryLockRepository defaultRepository =
      LocalDiaryLockRepository.instance;

  static const msgPinInvalido = 'Use 4 números.';
  static const msgPinIncorreto = 'PIN incorreto. Tente de novo.';
  static const msgPinsDiferentes = 'Os PINs não são iguais.';
  static const msgErro = 'Não foi possível salvar. Tente novamente.';

  final DiaryLockRepository repository;

  bool _isChecking = true;
  bool _isProtected = false;
  bool _isUnlocked = false;
  bool _isBusy = false;
  String? _errorMessage;

  /// Lendo se há PIN cadastrado (logo ao abrir a tela).
  bool get isChecking => _isChecking;

  /// Há PIN cadastrado.
  bool get isProtected => _isProtected;

  /// O diário pode ser mostrado (sem PIN ou já desbloqueado).
  bool get isUnlocked => _isUnlocked;

  /// Alguma operação em andamento.
  bool get isBusy => _isBusy;

  /// Motivo da última falha, para mostrar ao aluno.
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isChecking = true;
    notifyListeners();
    try {
      _isProtected = await repository.hasPin();
    } catch (error) {
      debugPrint('Erro ao ler o PIN do diário: $error');
      _isProtected = false;
    }
    _isUnlocked = !_isProtected;
    _isChecking = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Libera o diário se [pin] for o cadastrado.
  Future<bool> unlock(String pin) => _run(() async {
        if (!await repository.verify(pin)) return _fail(msgPinIncorreto);
        _isUnlocked = true;
        return true;
      });

  /// Cadastra o primeiro PIN.
  Future<bool> createPin(String pin, String confirmacao) => _run(() async {
        if (!_validarNovo(pin, confirmacao)) return false;
        await repository.setPin(pin);
        _isProtected = true;
        _isUnlocked = true;
        return true;
      });

  /// Troca o PIN, exigindo o atual.
  Future<bool> changePin(String atual, String novo, String confirmacao) =>
      _run(() async {
        if (!await repository.verify(atual)) return _fail(msgPinIncorreto);
        if (!_validarNovo(novo, confirmacao)) return false;
        await repository.setPin(novo);
        return true;
      });

  /// Remove a proteção, exigindo o PIN atual.
  Future<bool> removePin(String atual) => _run(() async {
        if (!await repository.verify(atual)) return _fail(msgPinIncorreto);
        await repository.removePin();
        _isProtected = false;
        _isUnlocked = true;
        return true;
      });

  bool _validarNovo(String pin, String confirmacao) {
    if (!DiaryLockRepository.isValidPin(pin)) return _fail(msgPinInvalido);
    if (pin != confirmacao) return _fail(msgPinsDiferentes);
    return true;
  }

  bool _fail(String message) {
    _errorMessage = message;
    return false;
  }

  Future<bool> _run(Future<bool> Function() action) async {
    if (_isBusy) return false;
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } catch (error) {
      debugPrint('Erro no PIN do diário: $error');
      return _fail(msgErro);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
