import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/chat/anonymous_chat_controller.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/modules/student/chat/repositories/chat_repository.dart';
import 'package:mente_leve/shared/models/report_model.dart';

import 'chat_test_support.dart';

void main() {
  group('AnonymousChatController (RF05)', () {
    late InMemoryChatRepository repository;
    late AnonymousChatController controller;

    setUp(() async {
      repository = InMemoryChatRepository();
      controller = AnonymousChatController(repository: repository)..start();
      await pumpEventQueue();
    });

    tearDown(() => controller.dispose());

    test('começa sem mensagens e sem assunto escolhido', () {
      expect(controller.isLoading, isFalse);
      expect(controller.messages, isEmpty);
      expect(controller.canChooseType, isTrue);
      expect(controller.selectedType, isNull);
      expect(controller.needsSubject, isTrue);
    });

    test('não envia sem o aluno escolher o assunto', () async {
      expect(await controller.send('Estão me zoando'), isFalse);
      await pumpEventQueue();

      expect(controller.errorMessage, contains('Escolha o assunto'));
      expect(controller.messages, isEmpty);

      controller.selectType(ReportType.bullying);
      expect(controller.needsSubject, isFalse);
      expect(await controller.send('Estão me zoando'), isTrue);
    });

    test('envia a mensagem sem espaços nas pontas e a mostra na conversa', () async {
      controller.selectType(ReportType.cyberbullying);
      final accepted = await controller.send('  Estão me zoando no grupo  ');
      await pumpEventQueue();

      expect(accepted, isTrue);
      expect(controller.messages, hasLength(1));
      expect(controller.messages.single.text, 'Estão me zoando no grupo');
      expect(controller.messages.single.isFromStudent, isTrue);
      expect(controller.status, ReportStatus.pending);
    });

    test('o tipo escolhido só vale antes da primeira mensagem', () async {
      controller.selectType(ReportType.cyberbullying);
      expect(controller.selectedType, ReportType.cyberbullying);

      await controller.send('primeira');
      await pumpEventQueue();
      controller.selectType(ReportType.other);

      expect(controller.canChooseType, isFalse);
      expect(controller.selectedType, ReportType.cyberbullying);
    });

    test('mensagem vazia ou só com espaços não é enviada', () async {
      expect(await controller.send(''), isFalse);
      expect(await controller.send('   \n '), isFalse);
      await pumpEventQueue();
      expect(controller.messages, isEmpty);
      expect(controller.errorMessage, isNull);
    });

    test('mensagem acima de 2000 caracteres é recusada com aviso', () async {
      final tooLong = 'a' * (AnonymousChatController.maxMessageLength + 1);

      expect(await controller.send(tooLong), isFalse);
      expect(controller.errorMessage, contains('2000'));
      expect(controller.messages, isEmpty);

      controller.selectType(ReportType.other);
      final exact = 'a' * AnonymousChatController.maxMessageLength;
      expect(await controller.send(exact), isTrue);
    });

    test('resposta da psicóloga chega em tempo real, sem recarregar', () async {
      controller.selectType(ReportType.bullying);
      await controller.send('Não consigo me concentrar nas aulas');
      await pumpEventQueue();
      expect(controller.messages, hasLength(1));

      repository.receive('Respire fundo. Estou aqui para ouvir você.');
      await pumpEventQueue();

      expect(controller.messages, hasLength(2));
      expect(controller.messages.last.sender, ChatSender.psychologist);
      expect(controller.messages.last.text, contains('Respire fundo'));
      expect(controller.status, ReportStatus.answered);
    });

    test('sem login no Firebase não envia e explica o motivo', () async {
      final offline = AnonymousChatController(
        repository: InMemoryChatRepository(available: false),
      )..start();
      await pumpEventQueue();

      expect(offline.canSend, isFalse);
      offline.selectType(ReportType.other);
      expect(await offline.send('oi'), isFalse);
      expect(offline.errorMessage, contains('Conecte-se à internet'));
      offline.dispose();
    });

    test('falha inesperada no envio mostra mensagem genérica', () async {
      final scripted = ScriptedChatRepository()..sendError = StateError('x');
      final failing = AnonymousChatController(repository: scripted)..start();
      await pumpEventQueue();

      failing.selectType(ReportType.other);
      expect(await failing.send('oi'), isFalse);
      expect(failing.errorMessage, contains('Tente novamente'));
      expect(failing.isSending, isFalse);

      failing.clearError();
      expect(failing.errorMessage, isNull);
      failing.dispose();
    });

    test('erro no tempo real mostra aviso e start() tenta de novo', () async {
      final scripted = ScriptedChatRepository()..failWatch = true;
      final c = AnonymousChatController(repository: scripted)..start();
      await pumpEventQueue();
      expect(c.loadError, isNotNull);
      expect(c.isLoading, isFalse);

      scripted.failWatch = false;
      c.start();
      await pumpEventQueue();
      scripted.emit(ChatThread(messages: [studentMessage('a', 'oi')]));
      await pumpEventQueue();

      expect(c.loadError, isNull);
      expect(c.messages, hasLength(1));
      expect(scripted.watchCalls, 2);
      c.dispose();
    });
  });

  group('mensagem de erro do tempo real', () {
    Future<String?> loadErrorFor(Object error) async {
      final repo = _ErroringChatRepository(error);
      final c = AnonymousChatController(repository: repo)..start();
      await pumpEventQueue();
      final message = c.loadError;
      c.dispose();
      return message;
    }

    test('permissão negada não culpa a conexão', () async {
      final message = await loadErrorFor(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      expect(message, contains('Sem permissão'));
      expect(message, isNot(contains('conexão')));
    });

    test('falta de rede do Firestore fala em conexão', () async {
      final message = await loadErrorFor(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
      expect(message, contains('Sem conexão'));
    });

    test('outros erros têm mensagem genérica', () async {
      final message = await loadErrorFor(StateError('x'));
      expect(message, contains('Não foi possível abrir a conversa'));
    });
  });

  group('ChatMessage.fromMap', () {
    test('lê o remetente e o texto, e marca pendente quando pedido', () {
      final message = ChatMessage.fromMap('m1', {
        'senderRole': 'psychologist',
        'text': 'Olá',
      }, isPending: true);

      expect(message.sender, ChatSender.psychologist);
      expect(message.text, 'Olá');
      expect(message.isPending, isTrue);
      expect(message.isFromStudent, isFalse);
    });

    test('remetente desconhecido nunca vira mensagem do aluno', () {
      expect(ChatSender.fromName('admin'), ChatSender.psychologist);
      expect(ChatSender.fromName(null), ChatSender.psychologist);
      expect(ChatSender.fromName('student'), ChatSender.student);
    });
  });
}

class _ErroringChatRepository implements ChatRepository {
  _ErroringChatRepository(this.error);

  final Object error;

  @override
  bool get isAvailable => true;

  @override
  Stream<ChatThread> watch() => Stream.error(error);

  @override
  Future<void> send({required String text, required ReportType type}) async {}
}
