import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/app_update/apk_installer.dart';
import 'package:mente_leve/shared/app_update/app_update_controller.dart';
import 'package:mente_leve/shared/app_update/app_update_dialog.dart';

import 'update_fakes.dart';

void main() {
  late Directory dir;
  late FakeRepository repository;
  late FakeDownloader downloader;
  late FakeInstaller installer;
  late AppUpdateController controller;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('update_dialog_');
    final apk = File('${dir.path}/app.apk')..writeAsStringSync('apk');
    repository = FakeRepository(testRelease);
    downloader = FakeDownloader(apk);
    installer = FakeInstaller();
    controller = AppUpdateController(
      repository: repository,
      downloader: downloader,
      installer: installer,
      currentVersion: () async => '1.0.0',
      isSupported: true,
    );
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> open(WidgetTester tester, {double textScale = 1}) async {
    await controller.check();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppUpdateDialogIfAvailable(context, controller),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('convida com tom acolhedor quando há versão nova', (tester) async {
    await open(tester);

    expect(find.text(AppUpdateDialog.availableTitle), findsOneWidget);
    expect(find.text(AppUpdateDialog.availableMessage), findsOneWidget);
    expect(find.text(AppUpdateDialog.updateLabel), findsOneWidget);
    expect(find.text(AppUpdateDialog.dismissLabel), findsOneWidget);
  });

  testWidgets('não abre quando não há atualização', (tester) async {
    repository.result = null;
    await open(tester);
    expect(find.text(AppUpdateDialog.availableTitle), findsNothing);
  });

  testWidgets('"Agora não" fecha o modal sem baixar nada', (tester) async {
    await open(tester);
    await tester.tap(find.text(AppUpdateDialog.dismissLabel));
    await tester.pumpAndSettle();

    expect(find.byType(AppUpdateDialog), findsNothing);
    expect(controller.status, AppUpdateStatus.idle);
    expect(downloader.calls, 0);
  });

  testWidgets('mostra a barra de progresso e bloqueia o fechamento', (
    tester,
  ) async {
    downloader.gate = Completer<void>();
    await open(tester);

    await tester.tap(find.text(AppUpdateDialog.updateLabel));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppUpdateDialog.downloadingTitle), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text(AppUpdateDialog.dismissLabel), findsNothing);

    // O botão voltar do sistema não fecha o modal durante o download.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AppUpdateDialog), findsOneWidget);

    downloader.gate!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('fecha sozinho quando o instalador é aberto', (tester) async {
    await open(tester);

    await tester.tap(find.text(AppUpdateDialog.updateLabel));
    await tester.pumpAndSettle();

    expect(installer.calls, 1);
    expect(controller.status, AppUpdateStatus.installerOpened);
    expect(find.byType(AppUpdateDialog), findsNothing);
  });

  testWidgets('permissão negada acolhe e oferece tentar de novo', (
    tester,
  ) async {
    installer.result = InstallResult.permissionDenied;
    await open(tester);
    await tester.tap(find.text(AppUpdateDialog.updateLabel));
    await tester.pumpAndSettle();

    expect(find.text(AppUpdateDialog.permissionTitle), findsOneWidget);

    installer.result = InstallResult.started;
    await tester.tap(find.text(AppUpdateDialog.retryLabel));
    await tester.pumpAndSettle();

    expect(find.byType(AppUpdateDialog), findsNothing);
    expect(downloader.calls, 1);
    expect(installer.calls, 2);
  });

  testWidgets('falha tranquiliza e permite tentar de novo ou fechar', (
    tester,
  ) async {
    downloader.error = StateError('sem rede');
    await open(tester);
    await tester.tap(find.text(AppUpdateDialog.updateLabel));
    await tester.pumpAndSettle();

    expect(find.text(AppUpdateDialog.failedTitle), findsOneWidget);
    expect(find.text(AppUpdateDialog.retryLabel), findsOneWidget);

    await tester.tap(find.text(AppUpdateDialog.dismissLabel));
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);
  });

  testWidgets('botões têm ao menos 48dp de altura', (tester) async {
    await open(tester);
    for (final label in [
      AppUpdateDialog.updateLabel,
      AppUpdateDialog.dismissLabel,
    ]) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('cabe na tela com fonte ampliada (200%)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await open(tester, textScale: 2);
    await tester.takeException(); // fontes de teste podem estourar na largura
    expect(find.text(AppUpdateDialog.updateLabel), findsOneWidget);
    expect(find.text(AppUpdateDialog.dismissLabel), findsOneWidget);
  });

  testWidgets('anuncia o título como cabeçalho para leitores de tela', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    expect(
      tester.getSemantics(find.text(AppUpdateDialog.availableTitle)),
      matchesSemantics(
        label: AppUpdateDialog.availableTitle,
        isHeader: true,
      ),
    );
    handle.dispose();
  });
}
