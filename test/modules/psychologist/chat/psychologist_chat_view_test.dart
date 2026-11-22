import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_controller.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_view.dart';
import 'package:mente_leve/modules/psychologist/chat/repositories/psychologist_chat_repository.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/shared/models/report_model.dart';

Report _report({ReportStatus status = ReportStatus.pending}) => Report(
  id: 'r1',
  type: ReportType.cyberbullying,
  description: 'Fizeram um grupo para me zoar',
  status: status,
  createdAt: DateTime(2026, 11, 20, 9),
  severity: ReportSeverity.high,
);

void main() {
  group('PsychologistChatView (RF10)', () {
    late InMemoryPsychologistChatRepository repository;

    Widget app({DateTime Function()? now}) => MaterialApp(
      home: PsychologistChatView(
        args: const ReportChatArgs(reportId: 'r1', protocol: '#003'),
        controller: PsychologistChatController(
          reportId: 'r1',
          repository: repository,
        ),
        now: now,
      ),
    );

    setUp(() {
      repository = InMemoryPsychologistChatRepository(
        _report(),
        messages: [
          ChatMessage(
            id: 'a',
            sender: ChatSender.student,
            text: 'Não consigo me concentrar nas aulas',
            createdAt: DateTime(2026, 11, 20, 9, 5),
          ),
        ],
      );
    });

    testWidgets('mostra o protocolo, a mensagem do aluno e o campo de resposta', (
      tester,
    ) async {
      await tester.pumpWidget(app(now: () => DateTime(2026, 11, 20, 18)));
      await tester.pumpAndSettle();

      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Mensagem anônima #003'), findsOneWidget);
      expect(find.text('Aluno anônimo'), findsOneWidget);
      expect(find.text('Não consigo me concentrar nas aulas'), findsOneWidget);
      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.text('Digite sua mensagem'), findsOneWidget);
      // A tela é só o chat: sem seletores de status, gravidade ou filtros.
      expect(find.byKey(const Key('psychologist_chat_manage')), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('responde ao aluno e o balão da psicóloga fica à direita', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_message_input')),
        'Respire fundo. Vamos conversar sobre isso.',
      );
      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pumpAndSettle();

      final reply = find.text('Respire fundo. Vamos conversar sobre isso.');
      expect(reply, findsOneWidget);
      // A resposta da psicóloga fica no lado direito da tela.
      expect(tester.getCenter(reply).dx, greaterThan(400));
      final field = tester.widget<TextField>(
        find.byKey(const Key('chat_message_input')),
      );
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('a mensagem do aluno chega em tempo real', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      repository.studentSays('Aconteceu de novo hoje');
      await tester.pumpAndSettle();

      expect(find.text('Aconteceu de novo hoje'), findsOneWidget);
    });

    testWidgets('mostra o texto do relato quando não há mensagens', (
      tester,
    ) async {
      repository = InMemoryPsychologistChatRepository(_report());
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Fizeram um grupo para me zoar'), findsOneWidget);
    });

    testWidgets('botões respeitam a área de toque mínima de 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      for (final key in ['chat_back_button', 'chat_send_button']) {
        final size = tester.getSize(find.byKey(Key(key)));
        expect(size.width, greaterThanOrEqualTo(48), reason: key);
        expect(size.height, greaterThanOrEqualTo(48), reason: key);
      }
    });
  });
}
