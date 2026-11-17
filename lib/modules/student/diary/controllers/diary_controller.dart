import 'package:flutter/foundation.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

/// Controlador responsável pelo fluxo de registro rápido de humor com emojis (RF01 / UC02).
///
/// Garante os seguintes requisitos:
/// - RNF05: Registro realizado em até 3 interações (1. Abrir tela -> 2. Tocar no emoji -> 3. Salvar).
/// - RNF02: Operação 100% offline.
/// - RNF03: Persistência local no dispositivo do aluno.
///
/// O aluno tem um sentimento por dia: salvar de novo no mesmo dia altera o
/// humor do registro de hoje (mantendo texto e pontos positivos) em vez de
/// criar outro registro.
class DiaryController extends ChangeNotifier {
  /// Repositório usado quando nenhum é injetado. O `main.dart` troca pelo
  /// `PrefsDiaryRepository` na inicialização; nos testes fica o de memória.
  static DiaryRepository defaultRepository = LocalDiaryRepository.instance;

  final DiaryRepository repository;

  DiaryController({DiaryRepository? repository, DateTime Function()? agora})
      : repository = repository ?? defaultRepository,
        _agora = agora ?? DateTime.now;

  /// Relógio injetável para os testes.
  final DateTime Function() _agora;

  Humor? _selectedHumor;
  bool _isLoading = false;
  bool _isSaved = false;
  String? _feedbackMessage;
  List<RegistroDiario> _entries = [];
  int _interactionCount = 1; // 1 = Tela aberta pelo aluno
  bool _lastSaveUpdated = false;

  /// Humor atualmente selecionado no seletor de emojis.
  Humor? get selectedHumor => _selectedHumor;

  /// Indicador de carregamento assíncrono.
  bool get isLoading => _isLoading;

  /// Indica se a seleção atual acabou de ser salva com sucesso.
  bool get isSaved => _isSaved;

  /// Mensagem acolhedora de feedback após registro ou aviso de erro.
  String? get feedbackMessage => _feedbackMessage;

  /// Lista de todos os registros já realizados pelo aluno (ordenados do mais recente ao mais antigo).
  List<RegistroDiario> get entries => List.unmodifiable(_entries);

  /// Último registro de humor cadastrado.
  RegistroDiario? get latestEntry => _entries.isNotEmpty ? _entries.first : null;

  /// Contador de interações do fluxo (usado para auditar o RNF05 de até 3 toques).
  int get interactionCount => _interactionCount;

  /// Indica se o botão de salvar está apto a ser acionado.
  bool get isReadyToSave => _selectedHumor != null && !_isLoading;

  /// Registro de hoje, se houver (o mais recente, caso existam dados antigos
  /// com mais de um registro no mesmo dia).
  RegistroDiario? get registroDeHoje {
    final now = _agora();
    for (final entry in _entries) {
      if (entry.dataHora.year == now.year &&
          entry.dataHora.month == now.month &&
          entry.dataHora.day == now.day) {
        return entry;
      }
    }
    return null;
  }

  /// Verifica se o aluno já realizou algum registro na data atual.
  bool get hasRecordedToday => registroDeHoje != null;

  /// Indica se o último salvamento alterou o registro de hoje em vez de
  /// criar um novo.
  bool get lastSaveUpdated => _lastSaveUpdated;

  /// Inicializa o controlador carregando os registros do diário local.
  Future<void> init() async {
    await loadEntries();
  }

  /// Carrega os registros persistidos localmente.
  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await repository.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Interação 2: Aluno seleciona um dos emojis de humor.
  void selectHumor(Humor humor) {
    if (_selectedHumor == humor && !_isSaved) return;
    _selectedHumor = humor;
    _isSaved = false;
    _feedbackMessage = null;
    _interactionCount = 2; // Emoji selecionado
    notifyListeners();
  }

  /// Interação 3: Aluno salva o humor selecionado no diário.
  ///
  /// Protegido contra reentrância / cliques repetidos rápidos durante escrita assíncrona.
  Future<bool> saveHumor() async {
    if (_selectedHumor == null || _isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Relê do repositório para não duplicar o dia se a lista estiver
      // desatualizada (ex.: registro feito na tela do diário reflexivo).
      _entries = await repository.getAll();
      final hoje = registroDeHoje;
      final now = _agora();

      final registro = hoje != null
          ? hoje.editar(humor: _selectedHumor)
          : RegistroDiario(
              id: now.microsecondsSinceEpoch.toString(),
              humor: _selectedHumor!,
              dataHora: now,
            );

      await repository.save(registro);
      _lastSaveUpdated = hoje != null;
      _entries = await repository.getAll();
      _isSaved = true;
      _feedbackMessage = _selectedHumor!.comfortingMessage;
      _interactionCount = 3; // Salvo com sucesso!
      return true;
    } catch (_) {
      _feedbackMessage = 'Não foi possível salvar seu humor. Tente novamente.';
      _isSaved = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Redefine a seleção atual para permitir um novo registro.
  void resetSelection() {
    _selectedHumor = null;
    _isSaved = false;
    _feedbackMessage = null;
    _interactionCount = 1;
    notifyListeners();
  }

  /// Exclui um registro local específico (UC05).
  Future<void> deleteEntry(String id) async {
    try {
      await repository.delete(id);
      _entries = await repository.getAll();
    } finally {
      notifyListeners();
    }
  }
}
