import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/diary_feelings_view.dart';
import 'package:mente_leve/modules/student/diary/diary_reflection_view.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/diary/repositories/prefs_diary_repository.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/prefs_mood_record_repository.dart';
import 'package:mente_leve/modules/student/support_trigger/repositories/support_trigger_state_store.dart';
import 'package:mente_leve/modules/student/support_trigger/support_modal_view.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late PrefsDiaryRepository diary;
  late SupportTriggerController trigger;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    diary = PrefsDiaryRepository(prefs);
    trigger = SupportTriggerController(
      records: PrefsMoodRecordRepository(prefs),
      stateStore: SupportTriggerStateStore(prefs),
    );
  });

  /// Grava registros nos dias anteriores a hoje, do mais antigo ao mais novo.
  Future<void> seedPreviousDays(List<Humor> humores) async {
    final now = DateTime.now();
    for (var i = 0; i < humores.length; i++) {
      final daysAgo = humores.length - i;
      await diary.save(
        RegistroDiario(
          id: 'dia-$daysAgo',
          humor: humores[i],
          dataHora: DateTime(now.year, now.month, now.day - daysAgo, 12),
        ),
      );
    }
  }

  /// Abre a roda de sentimentos sobre uma tela inicial, como a Home faz.
  Future<void> pumpFeelings(WidgetTester tester, Humor humor) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        routes: {HomeController.faqRoute: (_) => const Text('tela faq')},
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DiaryFeelingsView(
                  controller: DiaryController(repository: diary),
                  initialHumor: humor,
                  onMoodSaved: (context) => showSupportModalIfNeeded(
                    context,
                    availableRoutes: const {HomeController.faqRoute},
                    controller: trigger,
                    replaceCurrentRoute: true,
                  ),
                ),
              ),
            ),
            child: const Text('abrir diário'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir diário'));
    await tester.pumpAndSettle();
  }

  /// Não usa `pumpAndSettle`: o botão segue em "salvando" (com animação)
  /// enquanto o modal está aberto, o que impede salvar duas vezes.
  Future<void> saveMood(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('save_humor_button')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('roda de sentimentos', () {
    testWidgets('3º dia negativo salva o humor e mostra o modal', (
      tester,
    ) async {
      await tester.runAsync(
        () => seedPreviousDays([Humor.triste, Humor.ansioso]),
      );
      await pumpFeelings(tester, Humor.comRaiva);

      await saveMood(tester);

      expect(find.text(SupportModal.title), findsOneWidget);
      final saved = await tester.runAsync(diary.getLatest);
      expect(saved?.humor, Humor.comRaiva);
    });

    testWidgets('fechar o modal volta para a tela anterior', (tester) async {
      await tester.runAsync(
        () => seedPreviousDays([Humor.triste, Humor.triste]),
      );
      await pumpFeelings(tester, Humor.triste);
      await saveMood(tester);

      await tester.tap(find.text(SupportModal.dismissLabel));
      await tester.pumpAndSettle();

      expect(find.text(SupportModal.title), findsNothing);
      expect(find.byType(DiaryFeelingsView), findsNothing);
      expect(find.text('abrir diário'), findsOneWidget);
    });

    testWidgets('escolher o FAQ abre a tela no lugar do diário', (
      tester,
    ) async {
      await tester.runAsync(
        () => seedPreviousDays([Humor.triste, Humor.triste]),
      );
      await pumpFeelings(tester, Humor.triste);
      await saveMood(tester);

      await tester.tap(find.text(SupportModal.channelsLabel));
      await tester.pumpAndSettle();

      expect(find.text('tela faq'), findsOneWidget);
      expect(find.byType(DiaryFeelingsView), findsNothing);
    });

    testWidgets('sem sequência negativa fecha direto, sem modal', (
      tester,
    ) async {
      await tester.runAsync(
        () => seedPreviousDays([Humor.triste, Humor.feliz]),
      );
      await pumpFeelings(tester, Humor.triste);

      await saveMood(tester);

      expect(find.text(SupportModal.title), findsNothing);
      expect(find.text('abrir diário'), findsOneWidget);
    });
  });

  testWidgets('Diário Pessoal chama o gatilho depois de salvar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final DiaryRepository repository = LocalDiaryRepository();
    final now = DateTime.now();
    await tester.runAsync(
      () => repository.save(
        RegistroDiario(id: 'hoje', humor: Humor.triste, dataHora: now),
      ),
    );

    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: DiaryReflectionView(
          repository: repository,
          onMoodSaved: (context) async {
            calls++;
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('botao_anotar_diario')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('campo_texto_reflexivo')),
      'Dia difícil',
    );
    await tester.pumpAndSettle();
    final save = find.byKey(const Key('botao_registrar'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(calls, 1);
  });
}
