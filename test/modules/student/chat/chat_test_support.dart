import 'dart:async';

import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/modules/student/chat/repositories/chat_repository.dart';
import 'package:mente_leve/shared/models/report_model.dart';

/// Repositório de teste em que o teste decide o que a conversa emite, para
/// simular mensagens pendentes (sem internet) e falhas do tempo real.
class ScriptedChatRepository implements ChatRepository {
  ScriptedChatRepository({this.available = true});

  final bool available;
  final StreamController<ChatThread> _controller =
      StreamController<ChatThread>.broadcast();
  int watchCalls = 0;
  bool failWatch = false;
  Object? sendError;
  final List<({String text, ReportType type})> sent = [];

  @override
  bool get isAvailable => available;

  @override
  Stream<ChatThread> watch() async* {
    watchCalls++;
    if (failWatch) throw Exception('permission-denied');
    // Como o Firestore, a primeira emissão chega logo, antes de qualquer evento.
    yield ChatThread.empty;
    yield* _controller.stream;
  }

  void emit(ChatThread thread) => _controller.add(thread);

  @override
  Future<void> send({required String text, required ReportType type}) async {
    if (sendError != null) throw sendError!;
    sent.add((text: text, type: type));
  }
}

ChatMessage studentMessage(
  String id,
  String text, {
  DateTime? at,
  bool pending = false,
}) => ChatMessage(
  id: id,
  sender: ChatSender.student,
  text: text,
  createdAt: at ?? DateTime.now(),
  isPending: pending,
);

ChatMessage psychologistMessage(String id, String text, {DateTime? at}) =>
    ChatMessage(
      id: id,
      sender: ChatSender.psychologist,
      text: text,
      createdAt: at ?? DateTime.now(),
    );
