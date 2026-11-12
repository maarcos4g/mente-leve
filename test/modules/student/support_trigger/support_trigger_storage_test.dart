import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';
import 'package:mente_leve/modules/student/support_trigger/models/support_trigger_state.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/prefs_mood_record_repository.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/support_trigger_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('SupportTriggerStateStore', () {
    final state = SupportTriggerState(
      lastShownAt: DateTime(2026, 11, 12, 20, 30),
      countFrom: DateTime(2026, 11, 13),
    );

    test('lê estado vazio quando nada foi salvo', () async {
      final store = SupportTriggerStateStore(await prefsWith({}));
      expect(store.read(), SupportTriggerState.empty);
    });

    test('grava e lê o estado', () async {
      final prefs = await prefsWith({});
      await SupportTriggerStateStore(prefs).save(state);

      expect(SupportTriggerStateStore(prefs).read(), state);
      expect(
        jsonDecode(prefs.getString(SupportTriggerStateStore.storageKey)!),
        {
          'lastShownAt': '2026-11-12T20:30:00.000',
          'countFrom': '2026-11-13T00:00:00.000',
        },
      );
    });

    for (final corrupted in ['não é json', '[1, 2]', '{"countFrom": 42}']) {
      test('volta ao estado vazio se estiver corrompido: $corrupted', () async {
        final store = SupportTriggerStateStore(
          await prefsWith({SupportTriggerStateStore.storageKey: corrupted}),
        );
        expect(store.read(), SupportTriggerState.empty);
      });
    }

    test('clear() apaga só a chave do gatilho', () async {
      final prefs = await prefsWith({'profile': '{"nickname":"Panda"}'});
      final store = SupportTriggerStateStore(prefs);
      await store.save(state);

      await store.clear();

      expect(store.read(), SupportTriggerState.empty);
      expect(prefs.containsKey(SupportTriggerStateStore.storageKey), isFalse);
      expect(prefs.getString('profile'), isNotNull);
    });
  });

  group('PrefsMoodRecordRepository', () {
    final from = DateTime(2026, 11, 10);

    test('sem diário salvo, devolve lista vazia', () async {
      final repository = PrefsMoodRecordRepository(await prefsWith({}));
      expect(await repository.recordsSince(from), isEmpty);
    });

    test('lê o formato do diário e filtra pela data', () async {
      final diary = {
        'a': {'id': 'a', 'humor': 'triste', 'dataHora': '2026-11-12T09:00:00'},
        'b': {'id': 'b', 'humor': 'feliz', 'dataHora': '2026-11-01T09:00:00'},
        'c': {
          'id': 'c',
          'humor': 'comRaiva',
          'dataHora': '2026-11-10T00:00:00',
        },
        'quebrado': {'id': 'x', 'humor': 3},
      };
      final repository = PrefsMoodRecordRepository(
        await prefsWith({
          PrefsMoodRecordRepository.diaryKey: jsonEncode(diary),
        }),
      );

      expect(await repository.recordsSince(from), [
        MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 12, 9)),
        MoodRecord(mood: 'comRaiva', dateTime: DateTime(2026, 11, 10)),
      ]);
    });

    test('lança erro se o diário inteiro estiver corrompido', () async {
      final repository = PrefsMoodRecordRepository(
        await prefsWith({PrefsMoodRecordRepository.diaryKey: '{quebrado'}),
      );
      expect(repository.recordsSince(from), throwsA(anything));
    });
  });
}
