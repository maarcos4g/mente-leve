import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/report_model.dart';

/// Contrato de leitura das denúncias para o painel de triagem (RF09).
abstract class ReportRepository {
  /// Todas as denúncias, da mais recente para a mais antiga.
  Future<List<Report>> list();
}

/// Repositório em memória, usado nos testes e quando o Firestore não foi
/// injetado no bootstrap.
class LocalReportRepository implements ReportRepository {
  LocalReportRepository([List<Report> initial = const []])
    : _items = List<Report>.from(initial);

  final List<Report> _items;

  @override
  Future<List<Report>> list() async {
    final copy = List<Report>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(copy);
  }
}

/// Lê a coleção `reports` do Cloud Firestore. A regra de segurança só
/// libera a leitura da coleção inteira para a psicóloga.
///
/// Sem rede e sem cache, o erro sobe para o controller mostrar a mensagem
/// com a opção de tentar de novo.
class FirestoreReportRepository implements ReportRepository {
  FirestoreReportRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<Report>> list() async {
    final snap =
        await _firestore
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .get();
    return List.unmodifiable(
      snap.docs.map((doc) => Report.fromFirestore(doc, null)),
    );
  }
}
