import 'package:flutter/foundation.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

/// Controla o Diário Pessoal: escrita livre e pontos positivos do dia (RF02).
///
/// O texto e os pontos positivos ficam no mesmo [RegistroDiario] do humor
/// (RF01), como define `docs/modelagem/02-diagrama-de-classes.md`. "Anotar no
/// Diário" completa o registro de hoje, se existir; tocar num registro da
/// lista abre esse registro para edição.
class DiaryReflectionController extends ChangeNotifier {
  DiaryReflectionController({DiaryRepository? repository})
      : repository = repository ?? DiaryController.defaultRepository;

  final DiaryRepository repository;

  static const maxTextoLength = 2000;
  static const maxPontoLength = 40;

  /// Sugestões do checklist, com o emoji mostrado no chip
  /// (baseadas no protótipo "diario-reflexivo" do Figma).
  static const sugestoes = {
    'Ajudei um amigo': '🤝',
    'Tirei uma boa nota': '📚',
    'Me senti confiante': '🌟',
    'Dormi bem': '😴',
    'Ri de alguma coisa': '😂',
    'Conversei com alguém': '💬',
    'Fiz algo de que gosto': '🎨',
    'Me movimentei': '⚽',
  };

  /// Emoji de um ponto positivo; os escritos pelo aluno usam ✨.
  static String emojiDe(String ponto) => sugestoes[ponto] ?? '✨';

  // ---- Lista de registros ----
  List<RegistroDiario> _entries = [];
  bool _isLoading = false;

  List<RegistroDiario> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  // ---- Registro em edição (folha "Anotar no Diário") ----
  RegistroDiario? _editando;
  Humor? _humor;
  String _texto = '';
  final List<String> _pontos = [];
  final Set<String> _marcados = {};
  bool _isSaving = false;

  /// Registro sendo editado (nulo quando é um registro novo).
  RegistroDiario? get editando => _editando;
  Humor? get humor => _humor;
  String get texto => _texto;
  List<String> get pontos => List.unmodifiable(_pontos);
  bool get isSaving => _isSaving;
  bool isMarcado(String ponto) => _marcados.contains(ponto);

  /// Precisa de humor e de pelo menos um texto ou ponto positivo marcado.
  bool get canSave =>
      _humor != null &&
      (_texto.trim().isNotEmpty || _marcados.isNotEmpty) &&
      !_isSaving;

  /// Registro de hoje, se o aluno já fez algum.
  RegistroDiario? get registroDeHoje {
    final now = DateTime.now();
    return _entries.where((e) => _mesmoDia(e.dataHora, now)).firstOrNull;
  }

  /// Dias da semana atual (domingo a sábado) que têm registro.
  bool temRegistroEm(DateTime dia) =>
      _entries.any((e) => _mesmoDia(e.dataHora, dia));

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _entries = await repository.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Prepara a folha de escrita. Sem [registro], continua o registro de
  /// hoje (se houver) para não criar duplicados no mesmo dia.
  void abrir([RegistroDiario? registro]) {
    final alvo = registro ?? registroDeHoje;
    _editando = alvo;
    _humor = alvo?.humor;
    _texto = alvo?.texto ?? '';
    _pontos
      ..clear()
      ..addAll(sugestoes.keys);
    _marcados.clear();
    for (final ponto in alvo?.pontosPositivos ?? const <String>[]) {
      if (!_pontos.contains(ponto)) _pontos.add(ponto);
      _marcados.add(ponto);
    }
    notifyListeners();
  }

  void selectHumor(Humor humor) {
    _humor = humor;
    notifyListeners();
  }

  void setTexto(String value) {
    _texto = value;
    notifyListeners();
  }

  void togglePonto(String ponto) {
    if (!_marcados.remove(ponto)) _marcados.add(ponto);
    notifyListeners();
  }

  /// Adiciona um ponto positivo escrito pelo aluno, já marcado.
  /// Retorna `false` se estiver vazio, longo demais ou repetido.
  bool addPonto(String value) {
    final ponto = value.trim();
    if (ponto.isEmpty || ponto.length > maxPontoLength) return false;
    if (_pontos.any((p) => p.toLowerCase() == ponto.toLowerCase())) {
      return false;
    }
    _pontos.add(ponto);
    _marcados.add(ponto);
    notifyListeners();
    return true;
  }

  /// Salva no aparelho. Retorna `true` em caso de sucesso.
  Future<bool> save() async {
    if (!canSave) return false;

    _isSaving = true;
    notifyListeners();
    try {
      final texto = _texto.trim();
      // Mantém a ordem em que os pontos aparecem na tela.
      final marcados = _pontos.where(_marcados.contains).toList();
      final atual = _editando;

      final registro = atual != null
          ? atual.editar(
              humor: _humor,
              texto: texto.isEmpty ? null : texto,
              clearTexto: texto.isEmpty,
              pontosPositivos: marcados,
            )
          : RegistroDiario(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              humor: _humor!,
              texto: texto.isEmpty ? null : texto,
              pontosPositivos: marcados,
              dataHora: DateTime.now(),
            );

      await repository.save(registro);
      _editando = registro;
      _entries = await repository.getAll();
      return true;
    } catch (error) {
      debugPrint('Erro ao salvar o diário: $error');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Exclui um registro (UC05). A tela oferece "Desfazer" com [restore].
  Future<void> delete(RegistroDiario registro) async {
    _entries = _entries.where((e) => e.id != registro.id).toList();
    notifyListeners();
    await repository.delete(registro.id);
  }

  Future<void> restore(RegistroDiario registro) async {
    await repository.save(registro);
    await load();
  }

  /// Título do registro na lista: primeira linha do texto, ou o resumo
  /// dos pontos positivos, ou o humor.
  static String tituloDe(RegistroDiario registro) {
    if (registro.temTexto) {
      return registro.texto!.trim().split('\n').first;
    }
    final pontos = registro.pontosPositivos;
    if (pontos.isNotEmpty) {
      return pontos.length == 1
          ? pontos.first
          : '${pontos.first} e mais ${pontos.length - 1}';
    }
    return 'Me senti ${registro.humor.label.toLowerCase()}';
  }

  static bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
