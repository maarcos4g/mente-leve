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
  DiaryReflectionController({
    DiaryRepository? repository,
    DateTime Function()? agora,
  })  : repository = repository ?? DiaryController.defaultRepository,
        _agora = agora ?? DateTime.now {
    _inicioSemana = domingoDe(_agora());
  }

  final DiaryRepository repository;

  /// Relógio injetável, para os testes fixarem o "hoje".
  final DateTime Function() _agora;

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
    final now = _agora();
    return _entries.where((e) => _mesmoDia(e.dataHora, now)).firstOrNull;
  }

  /// Indica se algum registro foi feito em [dia].
  bool temRegistroEm(DateTime dia) =>
      _entries.any((e) => _mesmoDia(e.dataHora, dia));

  // ---- Calendário (histórico por semana) ----
  late DateTime _inicioSemana;
  DateTime? _diaSelecionado;

  DateTime get hoje {
    final now = _agora();
    return DateTime(now.year, now.month, now.day);
  }

  /// Domingo da semana exibida no calendário.
  DateTime get inicioSemana => _inicioSemana;

  /// Dias da semana exibida, de domingo a sábado.
  List<DateTime> get diasDaSemana => List.generate(
        7,
        (i) => DateTime(
            _inicioSemana.year, _inicioSemana.month, _inicioSemana.day + i),
      );

  /// Dia escolhido no calendário; nulo mostra todos os registros.
  DateTime? get diaSelecionado => _diaSelecionado;

  /// Só deixa avançar até a semana atual.
  bool get podeAvancar => _inicioSemana.isBefore(domingoDe(hoje));

  bool isHoje(DateTime dia) => _mesmoDia(dia, hoje);
  bool isFuturo(DateTime dia) => dia.isAfter(hoje) && !isHoje(dia);
  bool isSelecionado(DateTime dia) =>
      _diaSelecionado != null && _mesmoDia(dia, _diaSelecionado!);

  void semanaAnterior() {
    _inicioSemana = DateTime(
        _inicioSemana.year, _inicioSemana.month, _inicioSemana.day - 7);
    notifyListeners();
  }

  void proximaSemana() {
    if (!podeAvancar) return;
    _inicioSemana = DateTime(
        _inicioSemana.year, _inicioSemana.month, _inicioSemana.day + 7);
    notifyListeners();
  }

  /// Seleciona [dia] para ver os registros dele; tocar de novo desmarca.
  /// Dias futuros são ignorados.
  void selecionarDia(DateTime dia) {
    if (isFuturo(dia)) return;
    _diaSelecionado = isSelecionado(dia)
        ? null
        : DateTime(dia.year, dia.month, dia.day);
    notifyListeners();
  }

  /// Volta a mostrar todos os registros.
  void limparSelecao() {
    if (_diaSelecionado == null) return;
    _diaSelecionado = null;
    notifyListeners();
  }

  /// Registros mostrados na lista: os do dia selecionado ou todos.
  List<RegistroDiario> get entriesVisiveis {
    final dia = _diaSelecionado;
    if (dia == null) return entries;
    return List.unmodifiable(
        _entries.where((e) => _mesmoDia(e.dataHora, dia)));
  }

  static DateTime domingoDe(DateTime data) =>
      DateTime(data.year, data.month, data.day - data.weekday % 7);

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
              id: _agora().microsecondsSinceEpoch.toString(),
              humor: _humor!,
              texto: texto.isEmpty ? null : texto,
              pontosPositivos: marcados,
              dataHora: _agora(),
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
