import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';
import 'package:mente_leve/modules/student/support_trigger/models/support_trigger_state.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/mood_record_repository.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/support_trigger_state_store.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

final now = DateTime(2026, 11, 12, 20);

final negativeStreak = [
  MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, 10, 12)),
  MoodRecord(mood: 'ansioso', dateTime: DateTime(2026, 11, 11, 12)),
  MoodRecord(mood: 'comRaiva', dateTime: DateTime(2026, 11, 12, 19)),
];

class _FailingRecords implements MoodRecordRepository {
  @override
  Future<List<MoodRecord>> recordsSince(DateTime from) =>
      Future.error(StateError('falha de leitura'));
}

class _FailingStore implements SupportTriggerStateStore {
  @override
  SupportTriggerState read() => throw StateError('falha de leitura');

  @override
  Future<void> save(SupportTriggerState state) =>
      Future.error(StateError('falha de escrita'));

  @override
  Future<void> clear() async {}
}

Future<SupportTriggerStateStore> emptyStore() async {
  SharedPreferences.setMockInitialValues({});
  return SupportTriggerStateStore(await SharedPreferences.getInstance());
}

void main() {
  test('mostra com sequência negativa e não repete no mesmo dia', () async {
    final store = await emptyStore();
    final controller = SupportTriggerController(
      records: InMemoryMoodRecordRepository(negativeStreak),
      stateStore: store,
      clock: () => now,
    );

    expect(await controller.shouldShowAfterMoodSaved(), isTrue);

    await controller.markShown();
    expect(store.read().lastShownAt, now);
    expect(store.read().countFrom, DateTime(2026, 11, 13));
    expect(await controller.shouldShowAfterMoodSaved(), isFalse);
  });

  test('não mostra sem histórico', () async {
    final controller = SupportTriggerController(
      records: InMemoryMoodRecordRepository(),
      stateStore: await emptyStore(),
      clock: () => now,
    );
    expect(await controller.shouldShowAfterMoodSaved(), isFalse);
  });

  test('falha ao ler o histórico: não dispara e não lança erro', () async {
    final controller = SupportTriggerController(
      records: _FailingRecords(),
      stateStore: await emptyStore(),
      clock: () => now,
    );
    expect(await controller.shouldShowAfterMoodSaved(), isFalse);
  });

  test(
    'falha ao ler ou gravar o estado: não dispara e não lança erro',
    () async {
      final controller = SupportTriggerController(
        records: InMemoryMoodRecordRepository(negativeStreak),
        stateStore: _FailingStore(),
        clock: () => now,
      );
      expect(await controller.shouldShowAfterMoodSaved(), isFalse);
      await expectLater(controller.markShown(), completes);
    },
  );
}
