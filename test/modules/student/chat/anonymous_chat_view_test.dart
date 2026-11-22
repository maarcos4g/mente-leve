import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/chat/anonymous_chat_controller.dart';
import 'package:mente_leve/modules/student/chat/anonymous_chat_view.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/modules/student/chat/repositories/chat_repository.dart';
import 'package:mente_leve/shared/models/report_model.dart';

import 'chat_test_support.dart';

void main() {
  group('AnonymousChatView (RF05)', () {
    late InMemoryChatRepository repository;

    Widget app(
      ChatRepository repo, {
      DateTime Function()? now,
    }) => MaterialApp(
      home: AnonymousChatView(
        controller: AnonymousChatController(repository: repo),
        now: now,
      ),
    );

    setUp(() => repository = InMemoryChatRepository());

    testWidgets('mostra a apresentação anônima, o tipo e o campo de mensagem', (
      tester,
    ) async {
      await tester.pumpWidget(app(repository));
      await tester.pumpAndSettle();

      expect(find.text('Chat'), findsOneWidget);
      expect(find.byKey(const Key('chat_empty_intro')), findsOneWidget);
      expect(find.text('Conversa anônima'), findsOneWidget);
      expect(find.byKey(const Key('chat_type_bullying')), findsOneWidget);
      expect(find.byKey(const Key('chat_type_cyberbullying')), findsOneWidget);
      expect(find.byKey(const Key('chat_type_other')), findsOneWidget);
      expect(find.text('Digite sua mensagem'), findsOneWidget);
      expect(find.byKey(const Key('chat_unavailable_banner')), findsNothing);
    });

    testWidgets('envia a mensagem, limpa o campo e some com a apresentação', (
      tester,
    ) async {
      await tester.pumpWidget(app(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_message_input')),
        'Gostaria de conversar sobre o que aconteceu',
      );
      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Gostaria de conversar sobre o que aconteceu'),
        findsOneWidget,
      );
      expect(find.text('Hoje'), findsOneWidget);
      expect(find.byKey(const Key('chat_empty_intro')), findsNothing);
      final field = tester.widget<TextField>(
        find.byKey(const Key('chat_message_input')),
      );
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('a resposta da psicóloga aparece em tempo real', (
      tester,
    ) async {
      await tester.pumpWidget(app(repository));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_message_input')),
        'Posso conversar com a psicóloga?',
      );
      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pumpAndSettle();
      expect(find.text('Psicóloga'), findsNothing);

      // A psicóloga responde: a tela atualiza sozinha, sem nenhum toque.
      repository.receive('Claro! Podemos marcar um horário às 14h?');
      await tester.pumpAndSettle();

      expect(find.text('Psicóloga'), findsOneWidget);
      expect(
        find.text('Claro! Podemos marcar um horário às 14h?'),
        findsOneWidget,
      );
    });

    testWidgets('mensagem sem confirmação do servidor aparece como Enviando', (
      tester,
    ) async {
      final scripted = ScriptedChatRepository();
      await tester.pumpWidget(app(scripted));
      await tester.pumpAndSettle();

      scripted.emit(
        ChatThread(
          messages: [studentMessage('p1', 'Sem internet agora', pending: true)],
          status: ReportStatus.pending,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Enviando…'), findsOneWidget);

      // O Firestore sincroniza: a mesma mensagem passa a mostrar o horário.
      scripted.emit(
        ChatThread(
          messages: [
            studentMessage('p1', 'Sem internet agora', at: DateTime.now()),
          ],
          status: ReportStatus.pending,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Enviando…'), findsNothing);
    });

    testWidgets('separa as mensagens por dia (Hoje e Ontem)', (tester) async {
      final scripted = ScriptedChatRepository();
      final now = DateTime(2026, 11, 21, 15, 30);
      await tester.pumpWidget(app(scripted, now: () => now));
      await tester.pumpAndSettle();

      scripted.emit(
        ChatThread(
          messages: [
            studentMessage('a', 'ontem', at: DateTime(2026, 11, 20, 9, 5)),
            psychologistMessage('b', 'hoje', at: DateTime(2026, 11, 21, 8, 0)),
          ],
          status: ReportStatus.answered,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ontem'), findsOneWidget);
      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('o relato é criado com o tipo escolhido pelo aluno', (
      tester,
    ) async {
      final scripted = ScriptedChatRepository();
      await tester.pumpWidget(app(scripted));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_type_cyberbullying')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('chat_message_input')),
        'Prints no grupo da turma',
      );
      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pumpAndSettle();

      expect(scripted.sent.single.text, 'Prints no grupo da turma');
      expect(scripted.sent.single.type, ReportType.cyberbullying);
    });

    testWidgets('sem login no Firebase avisa e bloqueia o envio', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(InMemoryChatRepository(available: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('chat_unavailable_banner')), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(const Key('chat_message_input')),
      );
      expect(field.enabled, isFalse);
    });

    testWidgets('falha no envio mostra o aviso e mantém o texto digitado', (
      tester,
    ) async {
      final scripted = ScriptedChatRepository()..sendError = StateError('x');
      await tester.pumpWidget(app(scripted));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('chat_message_input')),
        'Minha mensagem',
      );
      await tester.tap(find.byKey(const Key('chat_send_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tente novamente'), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(const Key('chat_message_input')),
      );
      expect(field.controller!.text, 'Minha mensagem');
    });

    testWidgets('erro ao acompanhar a conversa oferece tentar de novo', (
      tester,
    ) async {
      final scripted = ScriptedChatRepository()..failWatch = true;
      await tester.pumpWidget(app(scripted));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chat_load_error')), findsOneWidget);

      scripted.failWatch = false;
      await tester.tap(find.byKey(const Key('chat_retry_button')));
      await tester.pumpAndSettle();
      scripted.emit(ChatThread(messages: [studentMessage('a', 'voltou')]));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('chat_load_error')), findsNothing);
      expect(find.text('voltou'), findsOneWidget);
    });

    testWidgets('botões respeitam a área de toque mínima de 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(app(repository));
      await tester.pumpAndSettle();

      for (final key in ['chat_back_button', 'chat_send_button']) {
        final size = tester.getSize(find.byKey(Key(key)));
        expect(size.width, greaterThanOrEqualTo(48), reason: key);
        expect(size.height, greaterThanOrEqualTo(48), reason: key);
      }
    });
  });
}
