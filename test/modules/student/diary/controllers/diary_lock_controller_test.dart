import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_lock_controller.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_lock_repository.dart';

void main() {
  late LocalDiaryLockRepository repo;

  setUp(() => repo = LocalDiaryLockRepository());

  Future<DiaryLockController> iniciar() async {
    final controller = DiaryLockController(repository: repo);
    await controller.init();
    return controller;
  }

  test('sem PIN o diário já fica liberado', () async {
    final controller = await iniciar();
    expect(controller.isChecking, isFalse);
    expect(controller.isProtected, isFalse);
    expect(controller.isUnlocked, isTrue);
  });

  test('com PIN o diário começa bloqueado', () async {
    await repo.setPin('1234');
    final controller = await iniciar();
    expect(controller.isProtected, isTrue);
    expect(controller.isUnlocked, isFalse);
  });

  test('unlock: PIN errado mostra erro, certo libera', () async {
    await repo.setPin('1234');
    final controller = await iniciar();

    expect(await controller.unlock('0000'), isFalse);
    expect(controller.errorMessage, DiaryLockController.msgPinIncorreto);
    expect(controller.isUnlocked, isFalse);

    expect(await controller.unlock('1234'), isTrue);
    expect(controller.errorMessage, isNull);
    expect(controller.isUnlocked, isTrue);
  });

  test('createPin valida formato e confirmação', () async {
    final controller = await iniciar();

    expect(await controller.createPin('12', '12'), isFalse);
    expect(controller.errorMessage, DiaryLockController.msgPinInvalido);

    expect(await controller.createPin('1234', '1235'), isFalse);
    expect(controller.errorMessage, DiaryLockController.msgPinsDiferentes);
    expect(await repo.hasPin(), isFalse);

    expect(await controller.createPin('1234', '1234'), isTrue);
    expect(controller.isProtected, isTrue);
    expect(controller.isUnlocked, isTrue);
    expect(await repo.verify('1234'), isTrue);
  });

  test('changePin exige o PIN atual', () async {
    await repo.setPin('1234');
    final controller = await iniciar();
    await controller.unlock('1234');

    expect(await controller.changePin('0000', '5678', '5678'), isFalse);
    expect(controller.errorMessage, DiaryLockController.msgPinIncorreto);

    expect(await controller.changePin('1234', '5678', '5679'), isFalse);
    expect(controller.errorMessage, DiaryLockController.msgPinsDiferentes);
    expect(await repo.verify('1234'), isTrue);

    expect(await controller.changePin('1234', '5678', '5678'), isTrue);
    expect(await repo.verify('5678'), isTrue);
    expect(controller.isProtected, isTrue);
  });

  test('removePin exige o PIN atual', () async {
    await repo.setPin('1234');
    final controller = await iniciar();
    await controller.unlock('1234');

    expect(await controller.removePin('9999'), isFalse);
    expect(controller.errorMessage, DiaryLockController.msgPinIncorreto);
    expect(await repo.hasPin(), isTrue);

    expect(await controller.removePin('1234'), isTrue);
    expect(controller.isProtected, isFalse);
    expect(await repo.hasPin(), isFalse);
  });
}
