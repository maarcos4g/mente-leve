import 'dart:convert';

import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/mood_record_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lê o histórico de humor direto do armazenamento local do diário.
///
/// Segue o formato do `PrefsDiaryRepository`: chave `diario` no
/// `SharedPreferences`, com um JSON `{id: registro}` em que cada registro tem
/// `humor` (nome do enum) e `dataHora` (ISO 8601).
///
/// Não usa `DiaryRepository.getAll` porque ele falha inteiro com um único
/// registro inválido, e isso desligaria o gatilho de apoio.
class PrefsMoodRecordRepository implements MoodRecordRepository {
  PrefsMoodRecordRepository(this._prefs);

  static const diaryKey = 'diario';

  final SharedPreferences _prefs;

  /// Lança erro se a chave inteira estiver corrompida (o controller trata).
  /// Um registro isolado em formato inesperado é ignorado.
  @override
  Future<List<MoodRecord>> recordsSince(DateTime from) async {
    final raw = _prefs.getString(diaryKey);
    if (raw == null) return const [];

    final data = jsonDecode(raw) as Map;
    final records = <MoodRecord>[];
    for (final value in data.values) {
      final record = _parse(value);
      if (record != null && !record.dateTime.isBefore(from)) {
        records.add(record);
      }
    }
    return records;
  }

  static MoodRecord? _parse(Object? value) {
    if (value is! Map) return null;
    final mood = value['humor'];
    final dateTime = DateTime.tryParse(value['dataHora']?.toString() ?? '');
    if (mood is! String || dateTime == null) return null;
    return MoodRecord(mood: mood, dateTime: dateTime);
  }
}
