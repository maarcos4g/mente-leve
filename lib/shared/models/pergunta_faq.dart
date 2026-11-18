import 'package:cloud_firestore/cloud_firestore.dart';

/// Entidade de pergunta e resposta do FAQ educativo (RF04, RF08).
///
/// Persistida na coleção `faq` do Cloud Firestore e em cache local
/// (`SharedPreferences`) para leitura offline (RNF02).
class PerguntaFaq {
  final String id;
  final String pergunta;
  final String resposta;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final String atualizadoPor;

  const PerguntaFaq({
    required this.id,
    required this.pergunta,
    required this.resposta,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.atualizadoPor,
  });

  /// Verifica se a pergunta ou a resposta contêm o [termo] buscado
  /// (case-insensitive). Quando [termo] está vazio, retorna `true`.
  bool corresponde(String termo) {
    final t = termo.trim().toLowerCase();
    return t.isEmpty ||
        pergunta.toLowerCase().contains(t) ||
        resposta.toLowerCase().contains(t);
  }

  PerguntaFaq copyWith({
    String? id,
    String? pergunta,
    String? resposta,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? atualizadoPor,
  }) {
    return PerguntaFaq(
      id: id ?? this.id,
      pergunta: pergunta ?? this.pergunta,
      resposta: resposta ?? this.resposta,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      atualizadoPor: atualizadoPor ?? this.atualizadoPor,
    );
  }

  factory PerguntaFaq.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
    SnapshotOptions? options,
  ) {
    final d = snap.data();
    if (d == null) {
      throw StateError('Documento de FAQ vazio ou inexistente: ${snap.id}');
    }
    return PerguntaFaq(
      id: snap.id,
      pergunta: (d['pergunta'] as String?) ?? '',
      resposta: (d['resposta'] as String?) ?? '',
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm:
          (d['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoPor: (d['atualizadoPor'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'pergunta': pergunta,
    'resposta': resposta,
    'criadoEm': Timestamp.fromDate(criadoEm),
    'atualizadoEm': FieldValue.serverTimestamp(),
    'atualizadoPor': atualizadoPor,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'pergunta': pergunta,
    'resposta': resposta,
    'criadoEm': criadoEm.toIso8601String(),
    'atualizadoEm': atualizadoEm.toIso8601String(),
    'atualizadoPor': atualizadoPor,
  };

  factory PerguntaFaq.fromMap(Map<dynamic, dynamic> map) {
    return PerguntaFaq(
      id: map['id'] as String,
      pergunta: map['pergunta'] as String,
      resposta: map['resposta'] as String,
      criadoEm:
          DateTime.tryParse(map['criadoEm'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      atualizadoEm:
          DateTime.tryParse(map['atualizadoEm'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      atualizadoPor: (map['atualizadoPor'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerguntaFaq &&
        other.id == id &&
        other.pergunta == pergunta &&
        other.resposta == resposta &&
        other.criadoEm == criadoEm &&
        other.atualizadoEm == atualizadoEm &&
        other.atualizadoPor == atualizadoPor;
  }

  @override
  int get hashCode =>
      Object.hash(id, pergunta, resposta, criadoEm, atualizadoEm, atualizadoPor);
}
