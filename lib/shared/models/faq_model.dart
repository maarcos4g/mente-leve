import 'package:cloud_firestore/cloud_firestore.dart';

/// Entidade de pergunta e resposta do FAQ educativo (RF04, RF08).
///
/// Persistida na coleção `faq` do Cloud Firestore (com campos em inglês,
/// seguindo o padrão da coleção `users`) e em cache local (`SharedPreferences`)
/// para leitura offline (RNF02).
class FaqModel {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedBy;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
  });

  /// Verifica se a pergunta ou a resposta contêm o termo [query] buscado
  /// (case-insensitive). Quando [query] está vazio, retorna `true`.
  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    return normalized.isEmpty ||
        question.toLowerCase().contains(normalized) ||
        answer.toLowerCase().contains(normalized);
  }

  FaqModel copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return FaqModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  factory FaqModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Documento de FAQ vazio ou inexistente: ${snapshot.id}');
    }
    return FaqModel(
      id: snapshot.id,
      question: (data['question'] as String?) ?? '',
      answer: (data['answer'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy: (data['updatedBy'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'question': question,
    'answer': answer,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': updatedBy,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'answer': answer,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'updatedBy': updatedBy,
  };

  factory FaqModel.fromMap(Map<dynamic, dynamic> map) {
    return FaqModel(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedBy: (map['updatedBy'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaqModel &&
        other.id == id &&
        other.question == question &&
        other.answer == answer &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.updatedBy == updatedBy;
  }

  @override
  int get hashCode =>
      Object.hash(id, question, answer, createdAt, updatedAt, updatedBy);
}
