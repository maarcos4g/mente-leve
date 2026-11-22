import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/app_update/apk_downloader.dart';
import 'package:mente_leve/shared/app_update/apk_installer.dart';
import 'package:mente_leve/shared/app_update/app_update_controller.dart';

import 'update_fakes.dart';

void main() {
  late Directory dir;
  late File apk;
  late FakeRepository repository;
  late FakeDownloader downloader;
  late FakeInstaller installer;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('update_controller_');
    apk = File('${dir.path}/app.apk')..writeAsStringSync('apk');
    repository = FakeRepository(testRelease);
    downloader = FakeDownloader(apk);
    installer = FakeInstaller();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  AppUpdateController build({bool isSupported = true}) => AppUpdateController(
    repository: repository,
    downloader: downloader,
    installer: installer,
    currentVersion: () async => '1.0.0',
    isSupported: isSupported,
  );

  group('check', () {
    test('marca como disponível quando há versão nova', () async {
      final controller = build();
      await controller.check();
      expect(controller.status, AppUpdateStatus.available);
      expect(controller.release?.tag, 'v1.1.0');
      expect(repository.askedWith, '1.0.0');
    });

    test('segue idle quando não há atualização', () async {
      repository.result = null;
      final controller = build();
      await controller.check();
      expect(controller.status, AppUpdateStatus.idle);
    });

    test('ignora erro do repositório sem lançar', () async {
      repository.error = StateError('falha');
      final controller = build();
      expect(await controller.check(), isNull);
      expect(controller.status, AppUpdateStatus.idle);
    });

    test('só consulta uma vez por execução', () async {
      final controller = build();
      await controller.check();
      await controller.check();
      expect(repository.calls, 1);
    });

    test('não consulta fora do Android', () async {
      final controller = build(isSupported: false);
      expect(await controller.check(), isNull);
      expect(repository.calls, 0);
    });
  });

  group('startUpdate', () {
    test('baixa, informa o progresso e abre o instalador', () async {
      final controller = build();
      await controller.check();

      final states = <AppUpdateStatus>[];
      final progress = <double?>[];
      controller.addListener(() {
        states.add(controller.status);
        progress.add(controller.progress);
      });
      await controller.startUpdate();

      expect(states, containsAllInOrder([
        AppUpdateStatus.downloading,
        AppUpdateStatus.installing,
        AppUpdateStatus.installerOpened,
      ]));
      expect(progress, contains(0.5));
      expect(installer.calls, 1);
      expect(controller.status, AppUpdateStatus.installerOpened);
    });

    test('falha no download vira failed e permite tentar de novo', () async {
      final controller = build();
      await controller.check();
      downloader.error = const ApkDownloadException('sem rede');

      await controller.startUpdate();
      expect(controller.status, AppUpdateStatus.failed);
      expect(installer.calls, 0);

      downloader.error = null;
      await controller.startUpdate();
      expect(controller.status, AppUpdateStatus.installerOpened);
      expect(downloader.calls, 2);
    });

    test('permissão negada mantém o APK e só repete a instalação', () async {
      final controller = build();
      await controller.check();
      installer.result = InstallResult.permissionDenied;

      await controller.startUpdate();
      expect(controller.status, AppUpdateStatus.permissionDenied);

      installer.result = InstallResult.started;
      await controller.startUpdate();
      expect(controller.status, AppUpdateStatus.installerOpened);
      expect(downloader.calls, 1, reason: 'não baixa o APK de novo');
      expect(installer.calls, 2);
    });

    test('falha ao abrir o instalador vira failed', () async {
      final controller = build();
      await controller.check();
      installer.result = InstallResult.failed;
      await controller.startUpdate();
      expect(controller.status, AppUpdateStatus.failed);
    });

    test('ignora toque duplo durante o download', () async {
      final controller = build();
      await controller.check();
      await Future.wait([controller.startUpdate(), controller.startUpdate()]);
      expect(downloader.calls, 1);
    });

    test('sem versão nova não faz nada', () async {
      repository.result = null;
      final controller = build();
      await controller.check();
      await controller.startUpdate();
      expect(downloader.calls, 0);
    });
  });

  test('dismiss volta para idle', () async {
    final controller = build();
    await controller.check();
    controller.dismiss();
    expect(controller.status, AppUpdateStatus.idle);
  });
}
