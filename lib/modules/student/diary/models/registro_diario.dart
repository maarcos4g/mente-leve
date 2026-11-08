import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';

/// Entidade do modelo de domínio que representa uma entrada no Diário
/// de Sentimentos do estudante (RF01, RF02, RF06).
///
/// Salvo exclusivamente no dispositivo do aluno (RNF01, RNF02, RNF03).
/// Especificado em:
/// - docs/modelagem/02-diagrama-de-classes.md
/// - docs/modelagem/04-mapeamento-dart-firestore.md
class RegistroDiario {
  final String id;
  final Humor humor;
  final String? texto;
  final List<String> pontosPositivos;
  final DateTime dataHora;

  const RegistroDiario({
    required this.id,
    required this.humor,
    this.texto,
    this.pontosPositivos = const [],
    required this.dataHora,
  });

  /// Indica se há escrita reflexiva associada ao registro (RF02).
  bool get temTexto => texto != null && texto!.trim().isNotEmpty;

  /// Retorna uma cópia atualizada do registro, permitindo edição.
  RegistroDiario editar({
    Humor? humor,
    String? texto,
    List<String>? pontosPositivos,
  }) {
    return RegistroDiario(
      id: id,
      humor: humor ?? this.humor,
      texto: texto ?? this.texto,
      pontosPositivos: pontosPositivos ?? this.pontosPositivos,
      dataHora: dataHora,
    );
  }

  /// Cria uma cópia com campos atualizados.
  RegistroDiario copyWith({
    String? id,
    Humor? humor,
    String? texto,
    List<String>? pontosPositivos,
    DateTime? dataHora,
  }) {
    return RegistroDiario(
      id: id ?? this.id,
      humor: humor ?? this.humor,
      texto: texto ?? this.texto,
      pontosPositivos: pontosPositivos ?? this.pontosPositivos,
      dataHora: dataHora ?? this.dataHora,
    );
  }

  /// Serialização para persistência local (JSON / Hive / SQLite).
  Map<String, dynamic> toMap() => {
        'id': id,
        'humor': humor.name,
        'texto': texto,
        'pontosPositivos': pontosPositivos,
        'dataHora': dataHora.toIso8601String(),
      };

  /// Desserialização a partir do mapa persistido.
  factory RegistroDiario.fromMap(Map<dynamic, dynamic> map) {
    return RegistroDiario(
      id: map['id'] as String,
      humor: Humor.values.byName(map['humor'] as String),
      texto: map['texto'] as String?,
      pontosPositivos: map['pontosPositivos'] != null
          ? List<String>.from(map['pontosPositivos'] as List)
          : const [],
      dataHora: DateTime.parse(map['dataHora'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistroDiario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          humor == other.humor &&
          texto == other.texto &&
          dataHora == other.dataHora;

  @override
  int get hashCode =>
      id.hashCode ^ humor.hashCode ^ (texto?.hashCode ?? 0) ^ dataHora.hashCode;

  @override
  String toString() =>
      'RegistroDiario(id: $id, humor: ${humor.name}, dataHora: $dataHora, temTexto: $temTexto)';
}
