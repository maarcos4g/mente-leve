import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo do relato, como no documento `reports/{id}` (`docs/modelagem/03-modelagem-firestore.md`).
enum ReportType {
  bullying('Bullying'),
  cyberbullying('Cyberbullying'),
  other('Outros');

  const ReportType(this.label);

  final String label;

  static ReportType fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return ReportType.other;
  }
}

/// Status de mediação da denúncia.
///
/// `pending` e `answered` já existem na modelagem; `inMediation` é o estado
/// intermediário em que a equipe já assumiu o relato, usado no filtro do
/// painel de triagem (RF09).
enum ReportStatus {
  pending('Pendente'),
  inMediation('Em mediação'),
  answered('Respondida');

  const ReportStatus(this.label);

  final String label;

  static ReportStatus fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    // Estado desconhecido nunca some da triagem: volta para a fila.
    return ReportStatus.pending;
  }
}

/// Nível de gravidade (criticidade) usado para priorizar a triagem.
///
/// O valor de [index] cresce com a gravidade (`low` < `medium` < `high`).
enum ReportSeverity {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const ReportSeverity(this.label);

  final String label;

  static ReportSeverity? tryFromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  /// Sinais de risco no texto do relato que elevam a gravidade para [high].
  /// Comparados sem acento e em minúsculas.
  static const List<String> _riskSignals = [
    'me matar',
    'suicid',
    'tirar minha vida',
    'acabar com tudo',
    'me machucar',
    'me cortar',
    'automutila',
    'ameac',
    'agred',
    'apanh',
    'espanc',
    'abuso',
    'abusa',
    'violencia',
    'arma',
    'faca',
    'sangue',
  ];

  /// Estima a gravidade quando o documento não traz o campo `severity`.
  ///
  /// Regra provisória, a validar com a equipe de psicologia: sinais de risco
  /// no texto => alta; bullying e cyberbullying => média; demais => baixa.
  static ReportSeverity infer(ReportType type, String description) {
    final texto = _stripAccents(description.toLowerCase());
    for (final signal in _riskSignals) {
      if (texto.contains(signal)) return ReportSeverity.high;
    }
    return type == ReportType.other
        ? ReportSeverity.low
        : ReportSeverity.medium;
  }

  static String _stripAccents(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'aaaaaeeeeiiiiooooouuuuc';
    final buffer = StringBuffer();
    for (final rune in texto.runes) {
      final char = String.fromCharCode(rune);
      final index = de.indexOf(char);
      buffer.write(index >= 0 ? para[index] : char);
    }
    return buffer.toString();
  }
}

/// Relato anônimo enviado pelo aluno, como a psicóloga o enxerga no painel
/// de triagem (RF09).
///
/// O `studentUid` do documento é deliberadamente ignorado: a triagem trabalha
/// só com o conteúdo do relato, para preservar o anonimato do aluno.
class Report {
  const Report({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.severity,
  });

  final String id;
  final ReportType type;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final ReportSeverity severity;

  bool get isPending => status == ReportStatus.pending;

  /// Lê o documento `reports/{id}`. Campos ausentes ou inválidos usam
  /// valores seguros, para um documento malformado não derrubar a triagem.
  factory Report.fromMap(String id, Map<String, dynamic> data) {
    final type = ReportType.fromName(data['type'] as String?);
    final description = (data['description'] as String?) ?? '';
    final rawCreatedAt = data['createdAt'];
    return Report(
      id: id,
      type: type,
      description: description,
      status: ReportStatus.fromName(data['status'] as String?),
      // Enquanto o servidor não confirma o horário, o campo vem nulo.
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : DateTime.now(),
      severity:
          ReportSeverity.tryFromName(data['severity'] as String?) ??
          ReportSeverity.infer(type, description),
    );
  }

  factory Report.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Documento de denúncia vazio: ${snapshot.id}');
    }
    return Report.fromMap(snapshot.id, data);
  }
}
