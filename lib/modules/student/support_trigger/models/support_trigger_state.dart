/// Estado de controle do gatilho de apoio, guardado só no aparelho (RN02, RN11).
///
/// Não identifica o aluno nem o que ele registrou: guarda apenas quando o
/// modal apareceu pela última vez e a partir de quando a sequência volta a
/// ser contada.
class SupportTriggerState {
  const SupportTriggerState({this.lastShownAt, this.countFrom});

  static const empty = SupportTriggerState();

  /// Último momento em que o modal foi exibido.
  final DateTime? lastShownAt;

  /// Registros anteriores a este momento não entram na sequência.
  final DateTime? countFrom;

  Map<String, dynamic> toMap() => {
    if (lastShownAt != null) 'lastShownAt': lastShownAt!.toIso8601String(),
    if (countFrom != null) 'countFrom': countFrom!.toIso8601String(),
  };

  /// Lança erro se o mapa estiver em formato inesperado; quem lê decide o
  /// que fazer (o `SupportTriggerStateStore` volta para o estado vazio).
  factory SupportTriggerState.fromMap(Map<dynamic, dynamic> map) {
    DateTime? parse(Object? raw) =>
        raw == null ? null : DateTime.parse(raw as String);
    return SupportTriggerState(
      lastShownAt: parse(map['lastShownAt']),
      countFrom: parse(map['countFrom']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SupportTriggerState &&
      other.lastShownAt == lastShownAt &&
      other.countFrom == countFrom;

  @override
  int get hashCode => Object.hash(lastShownAt, countFrom);

  @override
  String toString() =>
      'SupportTriggerState(lastShownAt: $lastShownAt, countFrom: $countFrom)';
}
