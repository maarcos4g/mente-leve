import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_controller.dart';
import 'package:mente_leve/modules/psychologist/chat/repositories/psychologist_chat_repository.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/shared/models/report_model.dart';

Report buildReport({
  ReportStatus status = ReportStatus.pending,
  ReportSeverity severity = ReportSeverity.medium,
}) => Report(
  id: 'r1',
  type: ReportType.bullying,
  description: 'Me chamam de apelido na sala',
  status: status,
  createdAt: DateTime(2026, 11, 20, 9),
  severity: severity,
);

/// Repositório que o teste controla, para simular falhas.
class ScriptedPsychologistChatRepository
    implements PsychologistChatRepository {
  final StreamController<ReportConversation> controller =
      StreamController<ReportConversation>.broadcast();
  bool failWatch = false;
  Object? writeError;
  int watchCalls = 0;
  final List<String> replies = [];

  @override
  Stream<ReportConversation> watch(String reportId) async* {
    watchCalls++;
    if (failWatch) throw FirebaseException(plugin: 'x', code: 'permission-denied');
    yield const ReportConversation();
    yield* controller.stream;
  }

  @override
  Future<void> reply({required String reportId, required String text}) async {
    if (writeError != null) throw writeError!;
    replies.add(text);
  }

}

void main() {
  group('PsychologistChatController (RF10)', () {
    late InMemoryPsychologistChatRepository repository;
    late PsychologistChatController controller;

    setUp(() async {
      repository = InMemoryPsychologistChatRepository(
        buildReport(),
        messages: [
          ChatMessage(
            id: 'a',
            sender: ChatSender.student,
            text: 'Estão me zoando no grupo',
            createdAt: DateTime(2026, 11, 20, 9),
          ),
        ],
      );
      controller = PsychologistChatController(
        reportId: 'r1',
        repository: repository,
      )..start();
      await pumpEventQueue();
    });

    tearDown(() => controller.dispose());

    test('carrega o relato e as mensagens do aluno', () {
      expect(controller.isLoading, isFalse);
      expect(controller.report?.id, 'r1');
      expect(controller.messages, hasLength(1));
      expect(controller.messages.single.isFromStudent, isTrue);
      expect(controller.notFound, isFalse);
    });

    test('a primeira resposta muda o relato pendente para respondido', () async {
      final ok = await controller.send('  Estou aqui para ouvir você  ');
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(controller.messages, hasLength(2));
      expect(controller.messages.last.sender, ChatSender.psychologist);
      expect(controller.messages.last.text, 'Estou aqui para ouvir você');
      expect(controller.report?.status, ReportStatus.answered);
    });

    test('responder um relato em mediação mantém a mediação', () async {
      final inMediation = PsychologistChatController(
        reportId: 'r1',
        repository: InMemoryPsychologistChatRepository(
          buildReport(status: ReportStatus.inMediation),
        ),
      )..start();
      await pumpEventQueue();

      await inMediation.send('Vamos conversar com a turma');
      await pumpEventQueue();

      expect(inMediation.report?.status, ReportStatus.inMediation);
      inMediation.dispose();
    });

    test('mensagem nova do aluno chega em tempo real e reabre o relato', () async {
      await controller.send('Pode contar comigo');
      await pumpEventQueue();
      expect(controller.report?.status, ReportStatus.answered);

      repository.studentSays('Obrigado, mas continuou hoje');
      await pumpEventQueue();

      expect(controller.messages.last.isFromStudent, isTrue);
      expect(controller.messages.last.text, contains('continuou hoje'));
      expect(controller.report?.status, ReportStatus.pending);
    });

    test('mensagem vazia não é enviada e acima de 2000 caracteres é recusada', () async {
      expect(await controller.send('   '), isFalse);
      expect(controller.errorMessage, isNull);

      final tooLong = 'a' * (PsychologistChatController.maxMessageLength + 1);
      expect(await controller.send(tooLong), isFalse);
      expect(controller.errorMessage, contains('2000'));
      expect(controller.messages, hasLength(1));
    });
  });

  group('PsychologistChatController: relato sem mensagens e falhas', () {
    test('relato criado sem mensagens mostra o texto como primeira mensagem', () async {
      final c = PsychologistChatController(
        reportId: 'r1',
        repository: InMemoryPsychologistChatRepository(buildReport()),
      )..start();
      await pumpEventQueue();

      expect(c.messages, hasLength(1));
      expect(c.messages.single.isFromStudent, isTrue);
      expect(c.messages.single.text, 'Me chamam de apelido na sala');
      c.dispose();
    });

    test('relato inexistente aparece como não encontrado', () async {
      final repo = ScriptedPsychologistChatRepository();
      final c = PsychologistChatController(reportId: 'x', repository: repo)
        ..start();
      await pumpEventQueue();

      expect(c.notFound, isTrue);
      c.dispose();
    });

    test('erro ao acompanhar mostra aviso e start() tenta de novo', () async {
      final repo = ScriptedPsychologistChatRepository()..failWatch = true;
      final c = PsychologistChatController(reportId: 'r1', repository: repo)
        ..start();
      await pumpEventQueue();
      expect(c.loadError, contains('Sem permissão'));

      repo.failWatch = false;
      c.start();
      await pumpEventQueue();
      expect(c.loadError, isNull);
      expect(repo.watchCalls, 2);
      c.dispose();
    });

    test('falha na escrita mostra mensagem e não trava o envio', () async {
      final repo = ScriptedPsychologistChatRepository()
        ..writeError = StateError('x');
      final c = PsychologistChatController(reportId: 'r1', repository: repo)
        ..start();
      await pumpEventQueue();

      expect(await c.send('oi'), isFalse);
      expect(c.errorMessage, contains('Tente novamente'));
      expect(c.isSending, isFalse);
      c.clearError();
      expect(c.errorMessage, isNull);
      c.dispose();
    });
  });
}
