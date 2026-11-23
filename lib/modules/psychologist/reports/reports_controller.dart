import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/reports/report_repository.dart';
import 'package:mente_leve/shared/utils/firestore_error_messages.dart';

/// Controlador do Painel de Gestão e Triagem de Relatos Anônimos (RF09).
///
/// Acompanha as denúncias em tempo real (novos relatos, respostas e mudanças
/// de status aparecem sozinhos) e entrega a lista na ordem de triagem: mais
/// grave primeiro e, na mesma gravidade, o relato mais antigo primeiro.
class ReportsController extends ChangeNotifier {
  ReportsController({ReportRepository? repository})
    : _repository =
          repository ?? defaultRepository ?? LocalReportRepository();

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static ReportRepository? defaultRepository;

  final ReportRepository _repository;

  List<Report> _all = const [];
  Map<String, int> _numbers = const {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _disposed = false;
  String? _errorMessage;
  StreamSubscription<List<Report>>? _subscription;

  bool get isLoading => _isLoading;

  /// `true` depois da primeira carga concluída (com sucesso ou erro).
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  /// Total de denúncias recebidas.
  int get total => _all.length;

  int get pendingCount => _all.where((d) => d.isPending).length;

  /// Todas as denúncias na ordem de triagem.
  List<Report> get sorted {
    final list = List<Report>.from(_all)..sort(_byTriage);
    return List.unmodifiable(list);
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

  /// (Re)começa a acompanhar os relatos. Completa na primeira emissão do
  /// repositório (dados ou erro), o que serve ao "puxar para atualizar".
  Future<void> load() {
    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final first = Completer<void>();
    void finish() {
      _isLoading = false;
      _hasLoaded = true;
      if (!_disposed) notifyListeners();
      if (!first.isCompleted) first.complete();
    }

    _subscription = _repository.watch().listen(
      (reports) {
        _setReports(reports);
        _errorMessage = null;
        finish();
      },
      onError: (Object error) {
        debugPrint('Triagem: falha ao acompanhar as denúncias: $error');
        _errorMessage = reportsLoadErrorMessage(error);
        finish();
      },
    );
    return first.future;
  }

  void _setReports(List<Report> reports) {
    _all = reports;
    final chronological = List<Report>.from(reports)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _numbers = {
      for (var i = 0; i < chronological.length; i++) chronological[i].id: i + 1,
    };
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
