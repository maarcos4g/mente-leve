import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/faq/student_faq_controller.dart';
import 'package:mente_leve/modules/student/faq/student_faq_view.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';

void main() {
  group('StudentFaqView Widget Tests (RF04 / SCRUM-33)', () {
    late LocalFaqRepository repository;
    late StudentFaqController controller;

    setUp(() {
      repository = LocalFaqRepository();
      controller = StudentFaqController(repository: repository);
    });

    Widget createWidget({
      Set<String> availableRoutes = const {},
      VoidCallback? onCvvPressed,
    }) {
      return MaterialApp(
        home: StudentFaqView(
          controller: controller,
          availableRoutes: availableRoutes,
          onCvvPressed: onCvvPressed,
        ),
      );
    }

    testWidgets('renderiza cabeçalho, canais de apoio e perguntas do FAQ', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Canais de Apoio & FAQ'), findsOneWidget);
      expect(find.text('Canais de Apoio'), findsOneWidget);
      expect(find.text('CVV - Centro de Valorização da vida'), findsOneWidget);
      expect(find.text('Denúncias anônimas à escola'), findsOneWidget);
      expect(find.text('FAQ e Dúvidas'), findsOneWidget);

      expect(find.text('O que é cyberbullying'), findsOneWidget);
      expect(find.text('Como lidar com a ansiedade?'), findsOneWidget);
      expect(find.text('Como pedir ajuda a um adulto?'), findsOneWidget);
      expect(find.text('Como saber se estou ansioso?'), findsOneWidget);

      // A pergunta de destaque inicia expandida conforme o protótipo
      expect(
        find.byKey(const Key('faq_answer_faq-lidar-ansiedade')),
        findsOneWidget,
      );
    });

    testWidgets('tocar em um card do FAQ expande e recolhe a resposta', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('faq_answer_faq-cyberbullying')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('faq_card_faq-cyberbullying')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('faq_answer_faq-cyberbullying')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('faq_card_faq-cyberbullying')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('faq_answer_faq-cyberbullying')),
        findsNothing,
      );
    });

    testWidgets('busca filtra perguntas em tempo real e permite limpar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('faq_search_field')),
        'cyberbullying',
      );
      await tester.pumpAndSettle();

      expect(find.text('O que é cyberbullying'), findsOneWidget);
      expect(find.text('Como pedir ajuda a um adulto?'), findsNothing);

      // Busca sem correspondência
      await tester.enterText(
        find.byKey(const Key('faq_search_field')),
        'termo_inexistente_xyz',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('faq_empty_message')), findsOneWidget);

      // Limpar busca
      await tester.tap(find.byKey(const Key('faq_clear_search_button')));
      await tester.pumpAndSettle();

      expect(find.text('Como pedir ajuda a um adulto?'), findsOneWidget);
    });

    testWidgets('canais de apoio acionam CVV e rota de denúncia', (
      tester,
    ) async {
      var cvvCalls = 0;
      await tester.pumpWidget(
        createWidget(onCvvPressed: () => cvvCalls++),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('support_channel_cvv')));
      await tester.pump();
      expect(cvvCalls, 1);

      await tester.tap(find.byKey(const Key('support_channel_report')));
      await tester.pump();
      expect(find.text('Disponível em breve.'), findsOneWidget);
    });

    testWidgets('renderiza sem overflow em tela estreita (320x640)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
