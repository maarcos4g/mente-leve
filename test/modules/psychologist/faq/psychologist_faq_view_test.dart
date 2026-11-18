import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_controller.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_view.dart';
import 'package:mente_leve/modules/psychologist/home/home_view.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';

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
          authorUid: 'psicologa-camila',
        ),
      );
    }

    testWidgets('renderiza formulário e lista de perguntas existentes', (
      tester,
    ) async {
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

      expect(find.text('O que é cyberbullying'), findsOneWidget);
      expect(find.text('Como lidar com a ansiedade?'), findsOneWidget);
    });

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

    testWidgets('edita e atualiza uma pergunta existente (Update)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final editButton = find.byKey(const Key('faq_edit_faq-cyberbullying'));
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
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

      await tester.tap(find.byKey(const Key('faq_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Pergunta atualizada com sucesso!'), findsOneWidget);
      expect(find.text('O que é cyberbullying e como agir?'), findsOneWidget);
      expect(
        find.text('Guarde evidências, bloqueie o agressor e avise a escola.'),
        findsOneWidget,
      );
    });

    testWidgets('exclui uma pergunta existente da lista (Delete)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('O que é cyberbullying'), findsOneWidget);

      final deleteButton = find.byKey(
        const Key('faq_delete_faq-cyberbullying'),
      );
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('O que é cyberbullying'), findsNothing);
      expect(find.text('Pergunta removida do FAQ.'), findsOneWidget);
    });

    testWidgets('PsychologistHomeView abre o painel de edição do FAQ', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => const PsychologistHomeView(),
            PsychologistFaqView.routeName:
                (_) => PsychologistFaqView(controller: controller),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar Perguntas Frequentes (FAQ)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('psychologist_open_faq_button')));
      await tester.pumpAndSettle();

      expect(find.text('Perguntas frequentes'), findsOneWidget);
    });
  });
}
