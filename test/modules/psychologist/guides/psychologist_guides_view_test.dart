import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/guides/psychologist_guides_controller.dart';
import 'package:mente_leve/modules/psychologist/guides/psychologist_guides_view.dart';
import 'package:mente_leve/modules/psychologist/home/home_view.dart';
import 'package:mente_leve/shared/guides/guide_repository.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/user_model.dart';

void main() {
  group('PsychologistGuidesView Widget Tests (RF08)', () {
    late LocalGuideRepository repository;

    setUp(() {
      repository = LocalGuideRepository();
    });

    testWidgets(
      'renderiza formulário e guias; editar e excluir só aparecem após arrastar para a esquerda',
      (tester) async {
        final controller = PsychologistGuidesController(repository: repository);

        await tester.pumpWidget(
          MaterialApp(
            home: PsychologistGuidesView(
              controller: controller,
              authorUid: 'psi-01',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Orientações'), findsOneWidget);
        expect(find.text('Guias e Orientações'), findsOneWidget);
        expect(
          find.text('Como identificar sinais de ansiedade?'),
          findsOneWidget,
        );

        expect(
          find.byKey(const Key('guide_edit_guide-sinais-ansiedade')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('guide_delete_guide-sinais-ansiedade')),
          findsNothing,
        );

        final swipeCard = find.byKey(
          const Key('guide_swipe_guide-sinais-ansiedade'),
        );
        await tester.ensureVisible(swipeCard);
        await tester.pumpAndSettle();
        await tester.drag(swipeCard, const Offset(-100, 0));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('guide_edit_guide-sinais-ansiedade')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('guide_delete_guide-sinais-ansiedade')),
          findsOneWidget,
        );
      },
    );

    testWidgets('valida campos obrigatórios antes de publicar guia', (
      tester,
    ) async {
      final controller = PsychologistGuidesController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: PsychologistGuidesView(
            controller: controller,
            authorUid: 'psi-01',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submit = find.byKey(const Key('guide_submit_button'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('guide_error_text')), findsOneWidget);
      expect(find.text('Informe o título do guia.'), findsOneWidget);
    });

    testWidgets('publica novo guia e exibe na lista imediatamente', (
      tester,
    ) async {
      final controller = PsychologistGuidesController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: PsychologistGuidesView(
            controller: controller,
            authorUid: 'psi-01',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('guide_title_field')),
        'Rotina de sono saudável',
      );
      await tester.tap(
        find.byKey(const Key('guide_category_chip_diálogo_em_família')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('guide_description_field')),
        'Como o descanso influencia o bem-estar emocional do adolescente.',
      );
      await tester.enterText(
        find.byKey(const Key('guide_text_field')),
        'Estabelecer horários regulares reduz irritabilidade e ansiedade.',
      );

      final submit = find.byKey(const Key('guide_submit_button'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Rotina de sono saudável'), findsOneWidget);
      expect(find.text('DIÁLOGO EM FAMÍLIA'), findsOneWidget);
    });

    testWidgets('edita e exclui guia após revelar ações com swipe-left', (
      tester,
    ) async {
      final controller = PsychologistGuidesController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: PsychologistGuidesView(
            controller: controller,
            authorUid: 'psi-01',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final swipeCard = find.byKey(
        const Key('guide_swipe_guide-sinais-ansiedade'),
      );
      await tester.ensureVisible(swipeCard);
      await tester.pumpAndSettle();
      await tester.drag(swipeCard, const Offset(-100, 0));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('guide_edit_guide-sinais-ansiedade')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Atualizar'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('guide_title_field')),
        'Sinais de ansiedade (Atualizado)',
      );

      final submit = find.byKey(const Key('guide_submit_button'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Sinais de ansiedade (Atualizado)'), findsOneWidget);

      await tester.ensureVisible(swipeCard);
      await tester.pumpAndSettle();
      await tester.drag(swipeCard, const Offset(-100, 0));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('guide_delete_guide-sinais-ansiedade')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('guide_confirm_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Sinais de ansiedade (Atualizado)'), findsNothing);
    });

    testWidgets(
      'PsychologistHomeView exibe card Guias e Orientações e navega para a tela',
      (tester) async {
        final user = UserModel(
          uid: 'psi-1',
          name: 'Dra. Camila',
          role: Role.psychologist,
          createdAt: DateTime.utc(2026, 11, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            routes: {
              PsychologistGuidesView.routeName:
                  (_) => PsychologistGuidesView(
                    controller: PsychologistGuidesController(
                      repository: repository,
                    ),
                  ),
            },
            home: PsychologistHomeView(user: user),
          ),
        );
        await tester.pumpAndSettle();

        final guidesCard = find.byKey(
          const Key('psychologist_open_guides_button'),
        );
        expect(guidesCard, findsOneWidget);

        await tester.ensureVisible(guidesCard);
        await tester.tap(guidesCard);
        await tester.pumpAndSettle();

        expect(find.text('Orientações'), findsOneWidget);
      },
    );
  });
}
