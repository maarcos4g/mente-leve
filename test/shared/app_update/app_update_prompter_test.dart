import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/app_update/app_update_controller.dart';
import 'package:mente_leve/shared/app_update/app_update_dialog.dart';
import 'package:mente_leve/shared/app_update/app_update_prompter.dart';

import 'update_fakes.dart';

void main() {
  late Directory dir;
  late FakeRepository repository;
  late AppUpdateController controller;
  late GlobalKey<NavigatorState> navigatorKey;
  late ValueNotifier<String?> route;
  late AppUpdatePrompter prompter;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('update_prompter_');
    repository = FakeRepository(testRelease);
    controller = AppUpdateController(
      repository: repository,
      downloader: FakeDownloader(File('${dir.path}/app.apk')),
      installer: FakeInstaller(),
      currentVersion: () async => '1.0.0',
      isSupported: true,
    );
    navigatorKey = GlobalKey<NavigatorState>();
    route = ValueNotifier<String?>('/splash');
    prompter = AppUpdatePrompter(
      controller: controller,
      navigatorKey: navigatorKey,
      currentRoute: route,
      homeRoutes: const {'/student/home'},
    );
  });

  tearDown(() {
    prompter.dispose();
    dir.deleteSync(recursive: true);
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(navigatorKey: navigatorKey, home: const Scaffold()),
  );

  testWidgets('abre o modal quando a versão nova chega e o app está na Home', (
    tester,
  ) async {
    await pumpApp(tester);
    route.value = '/student/home';
    prompter.start();
    await tester.pumpAndSettle();

    expect(find.text(AppUpdateDialog.availableTitle), findsOneWidget);
  });

  testWidgets('espera a Home: durante a splash não mostra nada', (tester) async {
    await pumpApp(tester);
    prompter.start();
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);

    route.value = '/student/home';
    await tester.pumpAndSettle();
    expect(find.text(AppUpdateDialog.availableTitle), findsOneWidget);
  });

  testWidgets('não interrompe o aluno em outras telas, como o diário', (
    tester,
  ) async {
    await pumpApp(tester);
    route.value = '/diary';
    prompter.start();
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);

    // Ao voltar para a Home, o modal aparece.
    route.value = '/student/home';
    await tester.pumpAndSettle();
    expect(find.text(AppUpdateDialog.availableTitle), findsOneWidget);
  });

  testWidgets('aparece só uma vez por execução', (tester) async {
    await pumpApp(tester);
    route.value = '/student/home';
    prompter.start();
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppUpdateDialog.dismissLabel));
    await tester.pumpAndSettle();

    route.value = '/diary';
    await tester.pump();
    route.value = '/student/home';
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);
  });

  testWidgets('sem atualização, o app segue sem modal', (tester) async {
    repository.result = null;
    await pumpApp(tester);
    route.value = '/student/home';
    prompter.start();
    await tester.pumpAndSettle();
    expect(find.byType(AppUpdateDialog), findsNothing);
  });

  testWidgets('falha na verificação é ignorada em silêncio', (tester) async {
    repository.error = const SocketException('offline');
    await pumpApp(tester);
    route.value = '/student/home';
    prompter.start();
    await tester.pumpAndSettle();

    expect(find.byType(AppUpdateDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
