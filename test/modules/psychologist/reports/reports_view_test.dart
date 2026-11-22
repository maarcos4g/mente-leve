import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_controller.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_view.dart';
import 'package:mente_leve/modules/psychologist/chat/repositories/psychologist_chat_repository.dart';
import 'package:mente_leve/modules/psychologist/home/home_view.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_controller.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_view.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';
import 'package:mente_leve/shared/reports/report_repository.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

import 'reports_test_support.dart';

void main() {
  group('ReportsView (RF09 / EPIC-06)', () {
    Widget app(ReportsController controller) =>
        MaterialApp(home: ReportsView(controller: controller));

    ReportsController withSamples() => ReportsController(
      repository: LocalReportRepository(sampleReports()),
    );

    Future<void> scrollTo(WidgetTester tester, Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('reports_list')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('lista as denúncias na ordem de triagem com selos', (
      tester,
    ) async {
      await tester.pumpWidget(app(withSamples()));
      await tester.pumpAndSettle();

      expect(find.text('Triagem de Denúncias'), findsOneWidget);
      expect(find.text('4 relatos (2 pendentes)'), findsOneWidget);
      expect(find.text('Mensagem anônima #002'), findsOneWidget);
      expect(find.text('Gravidade alta'), findsNWidgets(2));

      final first = tester.getTopLeft(find.byKey(const Key('report_card_d2')));
      final second = tester.getTopLeft(find.byKey(const Key('report_card_d4')));
      expect(first.dy, lessThan(second.dy));
    });

    testWidgets('estado vazio quando não há denúncias', (tester) async {
      await tester.pumpWidget(
        app(ReportsController(repository: LocalReportRepository())),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reports_empty')), findsOneWidget);
    });

    testWidgets('erro de carga mostra mensagem e tenta de novo', (
      tester,
    ) async {
      final repo = FailingReportRepository(sampleReports());
      await tester.pumpWidget(app(ReportsController(repository: repo)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reports_error')), findsOneWidget);

      repo.shouldFail = false;
      await tester.tap(find.byKey(const Key('reports_retry_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reports_error')), findsNothing);
      await scrollTo(tester, find.byKey(const Key('report_card_d1')));
      expect(find.byKey(const Key('report_card_d1')), findsOneWidget);
      expect(repo.calls, 2);
    });

    testWidgets('"Responder" abre o chat do relato com o protocolo', (
      tester,
    ) async {
      final chatRepo = InMemoryPsychologistChatRepository(
        sampleReports().firstWhere((r) => r.id == 'd4'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ReportsView(controller: withSamples()),
          onGenerateRoute: (settings) {
            if (settings.name != PsychologistChatView.routeName) return null;
            final args = settings.arguments as ReportChatArgs;
            return MaterialPageRoute<void>(
              settings: settings,
              builder:
                  (_) => PsychologistChatView(
                    args: args,
                    controller: PsychologistChatController(
                      reportId: args.reportId,
                      repository: chatRepo,
                    ),
                  ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final open = find.byKey(const Key('report_open_d4'));
      await scrollTo(tester, open);
      expect(
        find.descendant(of: open, matching: find.text('Responder')),
        findsOneWidget,
      );
      await tester.tap(open);
      await tester.pumpAndSettle();

      expect(find.text('Mensagem anônima #004'), findsOneWidget);
      expect(find.text('Ameaçaram me bater na saída'), findsOneWidget);
    });

    testWidgets('botão "Responder" segue o Figma: sky500, ícone undo, 16x4 e gap 8', (
      tester,
    ) async {
      await tester.pumpWidget(app(withSamples()));
      await tester.pumpAndSettle();

      final button = find.byKey(const Key('report_open_d2'));
      await scrollTo(tester, button);
      final surface =
          find.descendant(of: button, matching: find.byType(Material)).first;
      final icon = find.descendant(
        of: button,
        matching: find.byIcon(LucideIcons.undo),
      );
      final label = find.descendant(of: button, matching: find.text('Responder'));
      expect(icon, findsOneWidget);
      expect(label, findsOneWidget);

      expect(tester.widget<Material>(surface).color, AppColors.sky500);

      // Padding de 16 na horizontal e 4 na vertical, como no Figma.
      final style = tester.widget<ElevatedButton>(button).style!;
      expect(
        style.padding!.resolve(<WidgetState>{}),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );

      // Gap de 8 entre o ícone e o texto.
      final surfaceRect = tester.getRect(surface);
      final iconRect = tester.getRect(icon);
      final labelRect = tester.getRect(label);
      expect(labelRect.left - iconRect.right, 8);
      // Padding vertical de 4: o botão tem a altura do conteúdo mais 8.
      expect(surfaceRect.height, lessThan(36));
      // A área de toque continua com pelo menos 48dp.
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    });

    testWidgets('relato novo aparece em tempo real, sem recarregar', (
      tester,
    ) async {
      final repo = LocalReportRepository(sampleReports());
      await tester.pumpWidget(
        app(ReportsController(repository: repo)),
      );
      await tester.pumpAndSettle();
      expect(find.text('4 relatos (2 pendentes)'), findsOneWidget);

      repo.upsert(
        buildReport(
          'd5',
          description: 'Novo relato do aluno',
          createdAt: DateTime(2026, 11, 20, 10),
          severity: ReportSeverity.high,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 relatos (3 pendentes)'), findsOneWidget);
    });

    testWidgets('botões e chips respeitam a área de toque de 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(app(withSamples()));
      await tester.pumpAndSettle();

      for (final key in [
        'reports_back_button',
        'report_open_d2',
      ]) {
        final finder = find.byKey(Key(key));
        await tester.ensureVisible(finder);
        final size = tester.getSize(finder);
        expect(size.height, greaterThanOrEqualTo(48), reason: key);
      }
    });
  });

  group('Home da psicóloga: Triagem das denúncias', () {
    final user = UserModel(
      uid: 'psi-1',
      name: 'Camila',
      role: Role.psychologist,
      createdAt: DateTime(2026, 11, 1),
    );

    testWidgets('mostra as pendentes mais urgentes e abre o painel completo', (
      tester,
    ) async {
      ReportsController.defaultRepository = LocalReportRepository(
        sampleReports(),
      );
      addTearDown(() => ReportsController.defaultRepository = null);

      await tester.pumpWidget(
        MaterialApp(
          home: PsychologistHomeView(user: user),
          routes: {ReportsView.routeName: (_) => const ReportsView()},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Triagem das denúncias'), findsOneWidget);
      // Só pendentes: d4 (alta) e d1 (média); d2 (em mediação) fica de fora.
      expect(find.byKey(const Key('report_card_d4')), findsOneWidget);
      expect(find.byKey(const Key('report_card_d1')), findsOneWidget);
      expect(find.byKey(const Key('report_card_d2')), findsNothing);

      final openAll = find.byKey(const Key('psychologist_open_reports_button'));
      await tester.ensureVisible(openAll);
      await tester.tap(openAll);
      await tester.pumpAndSettle();
      expect(find.text('Triagem de Denúncias'), findsOneWidget);
      expect(find.byKey(const Key('report_card_d2')), findsOneWidget);
    });

    testWidgets('sem denúncias pendentes mostra o estado vazio', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: PsychologistHomeView(user: user)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reports_summary_empty')), findsOneWidget);
    });
  });
}
