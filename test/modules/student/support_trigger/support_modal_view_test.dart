import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/modules/student/support_trigger/models/mood_record.dart';
import 'package:mente_leve/modules/student/support_trigger/models/support_trigger_state.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/mood_record_repository.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/support_trigger_state_store.dart';
import 'package:mente_leve/modules/student/support_trigger/support_modal_view.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_controller.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _allRoutes = {HomeController.faqRoute, HomeController.reportRoute};

/// Tela de teste com um botão que abre o modal e as rotas de destino.
Future<void> _pumpHost(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  Set<String> availableRoutes = const {},
  Future<bool> Function()? onCallCvv,
  Future<void> Function(BuildContext context)? open,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    MaterialApp(
      routes: {
        for (final route in _allRoutes)
          route: (context) => Scaffold(body: Text('tela $route')),
      },
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () =>
                  open?.call(context) ??
                  showSupportModal(
                    context,
                    availableRoutes: availableRoutes,
                    onCallCvv: onCallCvv,
                  ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Finder _button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
);

void main() {
  for (final size in const [Size(390, 844), Size(360, 640)]) {
    testWidgets('mostra mensagem e todas as ações em '
        '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await _pumpHost(tester, size: size, availableRoutes: _allRoutes);

      expect(find.text(SupportModal.title), findsOneWidget);
      expect(find.text(SupportModal.message), findsOneWidget);
      expect(find.text(SupportModal.callLabel), findsOneWidget);
      expect(find.text(SupportModal.channelsLabel), findsOneWidget);
      expect(find.text(SupportModal.reportLabel), findsOneWidget);
      expect(find.text(SupportModal.dismissLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sem as telas de FAQ e de relato, mostra só CVV e "Agora não"', (
    tester,
  ) async {
    await _pumpHost(tester);

    expect(find.text(SupportModal.callLabel), findsOneWidget);
    expect(find.text(SupportModal.channelsLabel), findsNothing);
    expect(find.text(SupportModal.reportLabel), findsNothing);
    expect(find.text(SupportModal.dismissLabel), findsOneWidget);
  });

  testWidgets('"Agora não" fecha com um toque', (tester) async {
    await _pumpHost(tester, availableRoutes: _allRoutes);

    await tester.tap(find.text(SupportModal.dismissLabel));
    await tester.pumpAndSettle();

    expect(find.text(SupportModal.title), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('ações têm área de toque mínima de 48x48', (tester) async {
    await _pumpHost(tester, availableRoutes: _allRoutes);

    for (final label in [
      SupportModal.callLabel,
      SupportModal.channelsLabel,
      SupportModal.reportLabel,
      SupportModal.dismissLabel,
    ]) {
      final size = tester.getSize(_button(label));
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
    }
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('texto tem contraste AA nos modos claro e escuro', (
    tester,
  ) async {
    await _pumpHost(tester, availableRoutes: _allRoutes);
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.backgroundColor, AppColors.zinc900);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });

  testWidgets('fonte grande do sistema não quebra o layout', (tester) async {
    await _pumpHost(
      tester,
      size: const Size(360, 640),
      textScale: 2,
      availableRoutes: _allRoutes,
    );

    expect(find.text(SupportModal.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ligar para o CVV fecha o modal quando o discador abre', (
    tester,
  ) async {
    var calls = 0;
    await _pumpHost(
      tester,
      onCallCvv: () async {
        calls++;
        return true;
      },
    );

    await tester.tap(find.text(SupportModal.callLabel));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.text(SupportModal.title), findsNothing);
  });

  testWidgets('sem discador, avisa no modal e não fecha', (tester) async {
    await _pumpHost(tester, onCallCvv: () async => false);

    await tester.tap(find.text(SupportModal.callLabel));
    await tester.pumpAndSettle();

    expect(find.text(SupportModal.dialerFailedMessage), findsOneWidget);
    expect(find.text(SupportModal.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Canais de Apoio e FAQ abre a rota e fecha o modal', (
    tester,
  ) async {
    await _pumpHost(
      tester,
      open: (context) => showSupportModalIfNeeded(
        context,
        availableRoutes: _allRoutes,
        controller: _alwaysTrigger,
      ),
    );

    await tester.tap(find.text(SupportModal.channelsLabel));
    await tester.pumpAndSettle();

    expect(find.text(SupportModal.title), findsNothing);
    expect(find.text('tela ${HomeController.faqRoute}'), findsOneWidget);
  });

  group('showSupportModalIfNeeded', () {
    late SupportTriggerStateStore store;
    final now = DateTime(2026, 11, 12, 20);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = SupportTriggerStateStore(await SharedPreferences.getInstance());
    });

    SupportTriggerController controllerWith(List<String> moods) =>
        SupportTriggerController(
          records: InMemoryMoodRecordRepository([
            for (var i = 0; i < moods.length; i++)
              MoodRecord(
                mood: moods[i],
                dateTime: DateTime(2026, 11, 12 - (moods.length - 1 - i), 12),
              ),
          ]),
          stateStore: store,
          clock: () => now,
        );

    testWidgets('mostra o modal e grava o estado quando a regra dispara', (
      tester,
    ) async {
      final controller = controllerWith(['triste', 'ansioso', 'comRaiva']);
      await _pumpHost(
        tester,
        open: (context) => showSupportModalIfNeeded(
          context,
          availableRoutes: const {},
          controller: controller,
        ),
      );

      expect(find.text(SupportModal.title), findsOneWidget);
      expect(store.read().lastShownAt, now);
    });

    testWidgets('não mostra nada quando a regra não dispara', (tester) async {
      final controller = controllerWith(['triste', 'feliz', 'triste']);
      await _pumpHost(
        tester,
        open: (context) => showSupportModalIfNeeded(
          context,
          availableRoutes: const {},
          controller: controller,
        ),
      );

      expect(find.text(SupportModal.title), findsNothing);
      expect(store.read().lastShownAt, isNull);
    });
  });
}

/// Controller que sempre dispara (para testar a navegação do modal).
final _alwaysTrigger = SupportTriggerController(
  records: InMemoryMoodRecordRepository([
    for (var day = 10; day <= 12; day++)
      MoodRecord(mood: 'triste', dateTime: DateTime(2026, 11, day, 12)),
  ]),
  stateStore: _MemoryStateStore(),
  clock: () => DateTime(2026, 11, 12, 20),
);

class _MemoryStateStore implements SupportTriggerStateStore {
  @override
  SupportTriggerState read() => SupportTriggerState.empty;

  @override
  Future<void> save(SupportTriggerState state) async {}

  @override
  Future<void> clear() async {}
}
