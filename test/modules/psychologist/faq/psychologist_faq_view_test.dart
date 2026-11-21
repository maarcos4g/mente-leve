import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_controller.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_view.dart';
import 'package:mente_leve/modules/psychologist/home/home_view.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/user_model.dart';

void main() {
  group('PsychologistFaqView Widget Tests (RF08 / SCRUM-36)', () {
    late LocalFaqRepository repository;
    late PsychologistFaqController controller;

    setUp(() {
      repository = LocalFaqRepository();
      controller = PsychologistFaqController(repository: repository);
    });

    Widget createWidget() {
      return MaterialApp(
        home: PsychologistFaqView(
          controller: controller,
          authorUid: 'psychologist-uid',
        ),
      );
    }

    testWidgets(
      'renderiza formulário e oculta botões de editar/excluir até arrastar o card para a esquerda',
      (tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text('FAQ'), findsOneWidget);
        expect(find.text('Perguntas frequentes'), findsOneWidget);
        expect(
          find.text('Gerencie as perguntas acessadas pelo aluno no aplicativo'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('faq_title_input')), findsOneWidget);
        expect(find.byKey(const Key('faq_description_input')), findsOneWidget);
        expect(find.byKey(const Key('faq_submit_button')), findsOneWidget);
        expect(find.text('Salvar'), findsOneWidget);

        // Botões de editar e excluir NÃO devem estar visíveis antes do swipe
        expect(find.byKey(const Key('faq_edit_faq-cyberbullying')), findsNothing);
        expect(
          find.byKey(const Key('faq_delete_faq-cyberbullying')),
          findsNothing,
        );

        // Arrasta o card para a esquerda -> revela botões de editar e excluir
        final swipeTarget = find.byKey(const Key('faq_swipe_faq-cyberbullying'));
        await tester.ensureVisible(swipeTarget);
        await tester.drag(swipeTarget, const Offset(-100, 0));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('faq_edit_faq-cyberbullying')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('faq_delete_faq-cyberbullying')),
          findsOneWidget,
        );

        // Arrasta de volta para a direita -> oculta novamente
        await tester.drag(swipeTarget, const Offset(100, 0));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('faq_edit_faq-cyberbullying')), findsNothing);
        expect(
          find.byKey(const Key('faq_delete_faq-cyberbullying')),
          findsNothing,
        );
      },
    );

    testWidgets('valida campos obrigatórios antes de salvar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('faq_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe o título da pergunta'), findsOneWidget);
      expect(find.text('Informe a descrição da resposta'), findsOneWidget);
    });

    testWidgets('cadastra nova pergunta e resposta no FAQ (Create)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('faq_title_input')),
        'O que é empatia na escola?',
      );
      await tester.enterText(
        find.byKey(const Key('faq_description_input')),
        'Empatia é se colocar no lugar do outro e respeitar as diferenças.',
      );

      await tester.tap(find.byKey(const Key('faq_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Pergunta publicada no FAQ!'), findsOneWidget);
      expect(find.text('O que é empatia na escola?'), findsOneWidget);
      expect(
        find.text(
          'Empatia é se colocar no lugar do outro e respeitar as diferenças.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('edita e atualiza uma pergunta existente após arrastar para a esquerda (Update)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final swipeTarget = find.byKey(const Key('faq_swipe_faq-cyberbullying'));
      await tester.ensureVisible(swipeTarget);
      await tester.drag(swipeTarget, const Offset(-100, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('faq_edit_faq-cyberbullying')));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar'), findsOneWidget);
      expect(find.byKey(const Key('faq_cancel_edit_button')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('faq_title_input')),
        'O que é cyberbullying e como agir?',
      );
      await tester.enterText(
        find.byKey(const Key('faq_description_input')),
        'Guarde evidências, bloqueie o agressor e avise a escola.',
      );

      final submitBtn = find.byKey(const Key('faq_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Pergunta atualizada com sucesso!'), findsOneWidget);
      expect(find.text('O que é cyberbullying e como agir?'), findsOneWidget);
      expect(
        find.text('Guarde evidências, bloqueie o agressor e avise a escola.'),
        findsOneWidget,
      );
    });

    testWidgets('exclui uma pergunta existente após arrastar para a esquerda (Delete)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('O que é cyberbullying'), findsOneWidget);

      final swipeTarget = find.byKey(const Key('faq_swipe_faq-cyberbullying'));
      await tester.ensureVisible(swipeTarget);
      await tester.drag(swipeTarget, const Offset(-100, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('faq_delete_faq-cyberbullying')));
      await tester.pumpAndSettle();

      expect(find.text('O que é cyberbullying'), findsNothing);
      expect(find.text('Pergunta removida do FAQ.'), findsOneWidget);
    });

    testWidgets(
      'PsychologistHomeView exibe nome do Firestore, avatar na AppBar e card compacto de FAQ (152x142)',
      (tester) async {
        final firestoreUser = UserModel(
          uid: 'psi-01',
          name: 'Dra. Mariana',
          role: Role.psychologist,
          createdAt: DateTime.utc(2026, 11, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (_) => PsychologistHomeView(user: firestoreUser),
              PsychologistFaqView.routeName:
                  (_) => PsychologistFaqView(controller: controller),
            },
          ),
        );
        await tester.pumpAndSettle();

        // Nome vindo do Firestore (sem mock 'Camila')
        expect(find.text('Olá, Dra. Mariana!'), findsOneWidget);
        expect(find.text('Olá, Camila!'), findsNothing);

        // Avatar presente na AppBar
        expect(find.byKey(const Key('psychologist_avatar')), findsOneWidget);

        // Card compacto conforme Figma (152x142)
        final cardFinder = find.byKey(const Key('psychologist_open_faq_button'));
        expect(cardFinder, findsOneWidget);
        final cardSize = tester.getSize(cardFinder);
        expect(cardSize.width, 152);
        expect(cardSize.height, 142);

        await tester.tap(cardFinder);
        await tester.pumpAndSettle();

        expect(find.text('Perguntas frequentes'), findsOneWidget);
      },
    );
  });
}
