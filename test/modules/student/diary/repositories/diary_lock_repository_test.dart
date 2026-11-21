import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_lock_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DiaryLockRepository.isValidPin', () {
    test('aceita só 4 números', () {
      expect(DiaryLockRepository.isValidPin('1234'), isTrue);
      expect(DiaryLockRepository.isValidPin('0000'), isTrue);
      expect(DiaryLockRepository.isValidPin('123'), isFalse);
      expect(DiaryLockRepository.isValidPin('12345'), isFalse);
      expect(DiaryLockRepository.isValidPin('12a4'), isFalse);
      expect(DiaryLockRepository.isValidPin(''), isFalse);
    });
  });

  group('LocalDiaryLockRepository', () {
    test('cria, confere, troca e remove o PIN', () async {
      final repo = LocalDiaryLockRepository();
      expect(await repo.hasPin(), isFalse);
      expect(await repo.verify('1234'), isFalse);

      await repo.setPin('1234');
      expect(await repo.hasPin(), isTrue);
      expect(await repo.verify('1234'), isTrue);
      expect(await repo.verify('4321'), isFalse);

      await repo.setPin('9999');
      expect(await repo.verify('1234'), isFalse);
      expect(await repo.verify('9999'), isTrue);

      await repo.removePin();
      expect(await repo.hasPin(), isFalse);
    });
  });

  group('PrefsDiaryLockRepository', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('sem PIN cadastrado', () async {
      final repo = PrefsDiaryLockRepository(await SharedPreferences.getInstance());
      expect(await repo.hasPin(), isFalse);
      expect(await repo.verify('1234'), isFalse);
    });

    test('salva o PIN com hash, nunca em texto puro', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsDiaryLockRepository(prefs);
      await repo.setPin('1234');

      final raw = prefs.getString(PrefsDiaryLockRepository.storageKey);
      expect(raw, isNotNull);
      expect(raw, isNot(contains('1234')));
      expect(raw, contains('salt'));
      expect(raw, contains('hash'));
    });

    test('confere o PIN e persiste entre instâncias (offline)', () async {
      final prefs = await SharedPreferences.getInstance();
      await PrefsDiaryLockRepository(prefs).setPin('2580');

      final outra = PrefsDiaryLockRepository(prefs);
      expect(await outra.hasPin(), isTrue);
      expect(await outra.verify('2580'), isTrue);
      expect(await outra.verify('0000'), isFalse);
    });

    test('troca usa novo salt e invalida o PIN antigo', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsDiaryLockRepository(prefs);
      await repo.setPin('1234');
      final antes = prefs.getString(PrefsDiaryLockRepository.storageKey);

      await repo.setPin('1234');
      expect(prefs.getString(PrefsDiaryLockRepository.storageKey),
          isNot(antes));

      await repo.setPin('5678');
      expect(await repo.verify('1234'), isFalse);
      expect(await repo.verify('5678'), isTrue);
    });

    test('remove o PIN', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsDiaryLockRepository(prefs);
      await repo.setPin('1234');
      await repo.removePin();

      expect(await repo.hasPin(), isFalse);
      expect(prefs.containsKey(PrefsDiaryLockRepository.storageKey), isFalse);
    });

    test('dado corrompido conta como sem PIN (não tranca o aluno)', () async {
      SharedPreferences.setMockInitialValues(
          {PrefsDiaryLockRepository.storageKey: 'não é json'});
      final repo = PrefsDiaryLockRepository(await SharedPreferences.getInstance());
      expect(await repo.hasPin(), isFalse);

      SharedPreferences.setMockInitialValues(
          {PrefsDiaryLockRepository.storageKey: '{"salt": 1}'});
      final repo2 =
          PrefsDiaryLockRepository(await SharedPreferences.getInstance());
      expect(await repo2.hasPin(), isFalse);
    });
  });
}
