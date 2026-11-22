import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/report_model.dart';

/// Contrato de leitura dos relatos para o painel de triagem (RF09).
abstract class ReportRepository {
  /// Todos os relatos, do mais recente para o mais antigo.
  Future<List<Report>> list();

  /// Relatos em tempo real: emite a lista inteira a cada relato novo e a cada
  /// mudança de status, de gravidade ou de mensagem.
  Stream<List<Report>> watch();
}

/// Repositório em memória, usado nos testes e quando o Firestore não foi
/// injetado no bootstrap.
class LocalReportRepository implements ReportRepository {
  LocalReportRepository([List<Report> initial = const []])
    : _items = List<Report>.from(initial);

  final List<Report> _items;
  final StreamController<List<Report>> _changes =
      StreamController<List<Report>>.broadcast();

  List<Report> get _sorted {
    final copy = List<Report>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(copy);
  }

  /// Simula um relato novo (ou atualizado) chegando em tempo real.
  void upsert(Report report) {
    final index = _items.indexWhere((r) => r.id == report.id);
    if (index >= 0) {
      _items[index] = report;
    } else {
      _items.add(report);
    }
    _changes.add(_sorted);
  }

  @override
  Future<List<Report>> list() async => _sorted;

  @override
  Stream<List<Report>> watch() async* {
    yield _sorted;
    yield* _changes.stream;
  }
}

/// Lê a coleção `reports` do Cloud Firestore. A regra de segurança só libera
/// a leitura da coleção inteira para a psicóloga.
///
/// Sem rede e sem cache, o erro sobe para o controller mostrar a mensagem
/// com a opção de tentar de novo.
class FirestoreReportRepository implements ReportRepository {
  FirestoreReportRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Query<Map<String, dynamic>> get _query =>
      _firestore.collection('reports').orderBy('createdAt', descending: true);

  @override
  Future<List<Report>> list() async {
    final snap = await _query.get();
    return _toReports(snap);
  }

  @override
  Stream<List<Report>> watch() => _query.snapshots().map(_toReports);

  List<Report> _toReports(QuerySnapshot<Map<String, dynamic>> snap) {
    return List.unmodifiable(
      snap.docs.map((doc) => Report.fromFirestore(doc, null)),
    );
  }
}
