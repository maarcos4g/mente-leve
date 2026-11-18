import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';

/// Leitura do histórico de humor que o gatilho de apoio precisa (RN11).
///
/// O gatilho só lê: quem grava os registros é o diário (UC02). A leitura é
/// local e não usa internet (RN02).
abstract class MoodRecordRepository {
  /// Registros com `dateTime` igual ou posterior a [from], em qualquer ordem.
  Future<List<MoodRecord>> recordsSince(DateTime from);
}

/// Implementação em memória, usada nos testes.
class InMemoryMoodRecordRepository implements MoodRecordRepository {
  InMemoryMoodRecordRepository([Iterable<MoodRecord> records = const []])
    : _records = [...records];

  final List<MoodRecord> _records;

  void add(MoodRecord record) => _records.add(record);

  @override
  Future<List<MoodRecord>> recordsSince(DateTime from) async =>
      _records.where((record) => !record.dateTime.isBefore(from)).toList();
}
