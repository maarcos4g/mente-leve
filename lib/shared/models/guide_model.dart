import 'package:cloud_firestore/cloud_firestore.dart';

/// Guia informativo voltado aos pais e responsáveis, publicado pela psicóloga
/// escolar na coleção `guides/{guideId}` do Cloud Firestore (RF08, RF11).
///
/// Todos os campos seguem a nomenclatura em inglês padronizada em
/// `docs/modelagem/03-modelagem-firestore.md` (`title`, `description`, `text`,
/// `category`, `createdAt`, `updatedAt`, `authorUid`).
class GuideModel {
  const GuideModel({
    required this.id,
    required this.title,
    required this.description,
    required this.text,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.authorUid,
  });

  /// Categoria padrão exibida no card quando [category] não foi informada.
  static const String defaultCategory = 'Saúde Mental Juvenil';

  /// Sugestões rápidas de categoria usadas no formulário da psicóloga.
  static const List<String> suggestedCategories = [
    'Saúde Mental Juvenil',
    'Prevenção ao Bullying',
    'Diálogo em Família',
    'Segurança Digital',
  ];

  final String id;
  final String title;
  final String description;
  final String text;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorUid;

  /// Categoria formatada para exibição no card (usa [defaultCategory] se vazia).
  String get displayCategory {
    final trimmed = category?.trim();
    return (trimmed != null && trimmed.isNotEmpty) ? trimmed : defaultCategory;
  }

  GuideModel copyWith({
    String? id,
    String? title,
    String? description,
    String? text,
    String? category,
    bool clearCategory = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorUid,
  }) {
    return GuideModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      text: text ?? this.text,
      category: clearCategory ? null : (category ?? this.category),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorUid: authorUid ?? this.authorUid,
    );
  }

  factory GuideModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Documento de guia vazio: ${snapshot.id}');
    }
    return GuideModel.fromMap({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toFirestore() {
    final trimmedCategory = category?.trim();
    return {
      'title': title,
      'description': description,
      'text': text,
      if (trimmedCategory != null && trimmedCategory.isNotEmpty)
        'category': trimmedCategory,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (authorUid != null && authorUid!.isNotEmpty) 'authorUid': authorUid,
    };
  }

  Map<String, dynamic> toMap() {
    final trimmedCategory = category?.trim();
    return {
      'id': id,
      'title': title,
      'description': description,
      'text': text,
      if (trimmedCategory != null && trimmedCategory.isNotEmpty)
        'category': trimmedCategory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (authorUid != null && authorUid!.isNotEmpty) 'authorUid': authorUid,
    };
  }

  factory GuideModel.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    final created = _parseDate(map['createdAt']) ?? now;
    final updated = _parseDate(map['updatedAt']) ?? created;
    final rawCategory = _readString(map['category'])?.trim();
    final rawAuthor = _readString(map['authorUid'])?.trim();

    return GuideModel(
      id: _readString(map['id']) ?? '',
      title: _readString(map['title']) ?? '',
      description: _readString(map['description']) ?? '',
      text: _readString(map['text']) ?? '',
      category:
          (rawCategory != null && rawCategory.isNotEmpty) ? rawCategory : null,
      createdAt: created,
      updatedAt: updated,
      authorUid:
          (rawAuthor != null && rawAuthor.isNotEmpty) ? rawAuthor : null,
    );
  }

  static String? _readString(Object? value) => value is String ? value : null;

  static DateTime? _parseDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuideModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.text == text &&
        other.category == category &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.authorUid == authorUid;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    text,
    category,
    createdAt,
    updatedAt,
    authorUid,
  );
}
