import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/reports/report_repository.dart';

/// Controlador do Painel de Gestão e Triagem de Relatos Anônimos (RF09).
///
/// Carrega as denúncias, aplica os filtros de gravidade e de status de
/// mediação e entrega a lista na ordem de triagem: mais grave primeiro e,
/// na mesma gravidade, o relato mais antigo primeiro.
class ReportsController extends ChangeNotifier {
  ReportsController({ReportRepository? repository})
    : _repository =
          repository ?? defaultRepository ?? LocalReportRepository();

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static ReportRepository? defaultRepository;

  final ReportRepository _repository;

  List<Report> _all = const [];
  Map<String, int> _numbers = const {};
  ReportSeverity? _severityFilter;
  ReportStatus? _statusFilter;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  /// `true` depois da primeira carga concluída (com sucesso ou erro).
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  ReportSeverity? get severityFilter => _severityFilter;
  ReportStatus? get statusFilter => _statusFilter;
  bool get hasActiveFilters =>
      _severityFilter != null || _statusFilter != null;

  /// Total de denúncias recebidas, sem filtro.
  int get total => _all.length;

  int get pendingCount => _all.where((d) => d.isPending).length;

  /// Denúncias que passam pelos filtros atuais, na ordem de triagem.
  List<Report> get visible {
    final filtered =
        _all.where((d) {
          if (_severityFilter != null && d.severity != _severityFilter) {
            return false;
          }
          if (_statusFilter != null && d.status != _statusFilter) {
            return false;
          }
          return true;
        }).toList();
    filtered.sort(_byTriage);
    return List.unmodifiable(filtered);
  }

  /// Pendentes na ordem de triagem, para o resumo da Home.
  List<Report> pendingForTriage({int limit = 2}) {
    final pending = _all.where((d) => d.isPending).toList()
      ..sort(_byTriage);
    return List.unmodifiable(pending.take(limit));
  }

  /// Número do protocolo exibido no card ("Mensagem anônima #003"):
  /// posição do relato na ordem de chegada, da mais antiga (#001) em diante.
  String protocol(Report report) {
    final number = _numbers[report.id] ?? 0;
    return '#${number.toString().padLeft(3, '0')}';
  }

  static int _byTriage(Report a, Report b) {
    final bySeverity = b.severity.index.compareTo(a.severity.index);
    if (bySeverity != 0) return bySeverity;
    return a.createdAt.compareTo(b.createdAt);
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _all = await _repository.list();
      final chronological = List<Report>.from(_all)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _numbers = {
        for (var i = 0; i < chronological.length; i++)
          chronological[i].id: i + 1,
      };
    } catch (_) {
      _errorMessage =
          'Não foi possível carregar as denúncias. Verifique a conexão e '
          'tente novamente.';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  void filterBySeverity(ReportSeverity? severity) {
    if (_severityFilter == severity) return;
    _severityFilter = severity;
    notifyListeners();
  }

  void filterByStatus(ReportStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    if (!hasActiveFilters) return;
    _severityFilter = null;
    _statusFilter = null;
    notifyListeners();
  }
}
