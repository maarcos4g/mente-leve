import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/parents/home/home_view.dart';
import 'package:mente_leve/modules/parents/home/parents_home_controller.dart';
import 'package:mente_leve/shared/guides/guide_repository.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/guide_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';

class _FailingGuideRepository implements GuideRepository {
  bool shouldFail = true;

  @override
  Future<List<GuideModel>> list() async {
    if (shouldFail) throw Exception('sem rede');
    return defaultGuideItems;
  }

  @override
  Future<GuideModel> create({
    required String title,
    required String description,
    required String text,
    String? category,
    required String authorUid,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<GuideModel> update(GuideModel item) => throw UnimplementedError();
}

void main() {
  group('ParentsHomeView Widget Tests (RF11)', () {
    testWidgets(
      'exibe saudação com nome do Firestore, banner Fale com a escola e abre leitura do guia',
      (tester) async {
        final repo = LocalGuideRepository();
        final controller = ParentsHomeController(repository: repo);
        final parentUser = UserModel(
          uid: 'parent-1',
          name: 'Maria Silva',
          role: Role.parent,
          createdAt: DateTime.utc(2026, 11, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ParentsHomeView(user: parentUser, controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Olá, Maria!'), findsOneWidget);
        expect(
          find.text('Apoiando o desenvolvimento socioemocional'),
          findsOneWidget,
        );
        expect(find.text('Fale com a escola'), findsOneWidget);
        expect(find.text('Guias e Orientações'), findsOneWidget);
        expect(
          find.text('Como identificar sinais de ansiedade?'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('guide_card_guide-sinais-ansiedade')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('guide_detail_title')), findsOneWidget);
        expect(
          find.textContaining('Sentir nervosismo antes de uma prova'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('guide_detail_back_button')));
        await tester.pumpAndSettle();

        expect(find.text('Guias e Orientações'), findsOneWidget);
      },
    );

    testWidgets(
      'usa fallback "Olá, Família!" e abre modal institucional ao tocar em Fale com a escola',
      (tester) async {
        final controller = ParentsHomeController(
          repository: LocalGuideRepository(),
        );

        await tester.pumpWidget(
          MaterialApp(home: ParentsHomeView(controller: controller)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Olá, Família!'), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('parents_contact_school_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('agendar atendimento com a psicóloga escolar'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('parents_sheet_dial_cvv_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('exibe estado vazio quando não há guias publicados', (
      tester,
    ) async {
      final controller = ParentsHomeController(
        repository: LocalGuideRepository(initial: const []),
      );

      await tester.pumpWidget(
        MaterialApp(home: ParentsHomeView(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('parents_guides_empty')), findsOneWidget);
      expect(
        find.text('Nenhum guia publicado até o momento.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'exibe estado de erro e recarrega ao tocar em Tentar novamente',
      (tester) async {
        final repo = _FailingGuideRepository();
        final controller = ParentsHomeController(repository: repo);

        await tester.pumpWidget(
          MaterialApp(home: ParentsHomeView(controller: controller)),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('parents_guides_error')), findsOneWidget);

        repo.shouldFail = false;
        await tester.tap(find.byKey(const Key('parents_guides_retry_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Como identificar sinais de ansiedade?'),
          findsOneWidget,
        );
      },
    );

    testWidgets('renderiza sem overflow em tela compacta 360x640', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ParentsHomeController(
        repository: LocalGuideRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(home: ParentsHomeView(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Guias e Orientações'), findsOneWidget);
    });
  });
}
