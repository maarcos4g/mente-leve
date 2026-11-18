/// Recorte de um registro do diário usado pelo gatilho de apoio (RN11).
///
/// O gatilho só precisa do humor e da data/hora, então não depende da classe
/// completa do diário (`RegistroDiario`). [mood] guarda o nome do enum `Humor`
/// do jeito que o diário grava (`humor.name`, ex.: `"comRaiva"`).
class MoodRecord {
  const MoodRecord({required this.mood, required this.dateTime});

  final String mood;
  final DateTime dateTime;

  @override
  bool operator ==(Object other) =>
      other is MoodRecord && other.mood == mood && other.dateTime == dateTime;

  @override
  int get hashCode => Object.hash(mood, dateTime);

  @override
  String toString() => 'MoodRecord($mood, $dateTime)';
}
