import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/shared/models/report_model.dart';

/// O aluno não está conectado ao Firebase (sessão local, sem internet no
/// primeiro acesso), então não há como gravar o relato.
class ChatUnavailableException implements Exception {
  const ChatUnavailableException();
}

/// Contrato do chat anônimo do aluno com a escola (RF05).
abstract class ChatRepository {
  /// `false` quando não há login no Firebase para enviar mensagens.
  bool get isAvailable;

  /// Conversa em tempo real: emite a cada mensagem nova, inclusive as da
  /// psicóloga, e a cada mudança de status do relato.
  Stream<ChatThread> watch();

  /// Envia uma mensagem. A primeira mensagem cria o relato (com [type]).
  Future<void> send({required String text, required ReportType type});
}

/// Repositório em memória, usado nos testes e quando o Firestore não foi
/// injetado no bootstrap. Nada é gravado fora do aparelho.
class InMemoryChatRepository implements ChatRepository {
  InMemoryChatRepository({this.available = true});

  final bool available;
  final List<ChatMessage> _messages = [];
  final StreamController<ChatThread> _controller =
      StreamController<ChatThread>.broadcast();
  int _counter = 0;
  ReportStatus? _status;

  @override
  bool get isAvailable => available;

  ChatThread get _thread =>
      ChatThread(messages: List.unmodifiable(_messages), status: _status);

  @override
  Stream<ChatThread> watch() async* {
    yield _thread;
    yield* _controller.stream;
  }

  @override
  Future<void> send({required String text, required ReportType type}) async {
    if (!available) throw const ChatUnavailableException();
    _status ??= ReportStatus.pending;
    _add(ChatSender.student, text);
  }

  /// Simula uma mensagem que chega da psicóloga em tempo real.
  void receive(String text, {ReportStatus status = ReportStatus.answered}) {
    _status = status;
    _add(ChatSender.psychologist, text);
  }

  void _add(ChatSender sender, String text) {
    _counter++;
    _messages.add(
      ChatMessage(
        id: 'm$_counter',
        sender: sender,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    _controller.add(_thread);
  }
}

/// Chat em tempo real sobre o Cloud Firestore.
///
/// A conversa do aluno é o documento `reports/{uid}` (o id é o uid da
/// autenticação anônima) com as mensagens em `reports/{uid}/messages`.
/// Sem internet, o Firestore guarda a escrita numa fila local e envia quando
/// a conexão volta; enquanto isso a mensagem aparece como pendente.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(
    this._firestore,
    this._auth, {
    this.queueTimeout = const Duration(seconds: 3),
  });

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Sem rede o `commit` só termina quando o servidor responde. Passado este
  /// prazo a mensagem é tratada como "na fila" e a tela segue em frente.
  final Duration queueTimeout;

  ReportStatus? _status;

  @override
  bool get isAvailable => _auth.currentUser != null;

  DocumentReference<Map<String, dynamic>>? get _report {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _firestore.collection('reports').doc(uid);
  }

  @override
  Stream<ChatThread> watch() {
    final report = _report;
    if (report == null) return Stream.value(ChatThread.empty);

    late final StreamController<ChatThread> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? reportSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? messagesSub;
    var messages = const <ChatMessage>[];

    void emit() {
      if (!controller.isClosed) {
        controller.add(ChatThread(messages: messages, status: _status));
      }
    }

    controller = StreamController<ChatThread>(
      onListen: () {
        reportSub = report
            .snapshots(includeMetadataChanges: true)
            .listen((snap) {
              _status =
                  snap.exists
                      ? ReportStatus.fromName(snap.data()?['status'] as String?)
                      : null;
              emit();
            }, onError: controller.addError);
        messagesSub = report
            .collection('messages')
            .orderBy('createdAt')
            .snapshots(includeMetadataChanges: true)
            .listen((snap) {
              messages = List.unmodifiable(
                snap.docs.map(
                  (doc) => ChatMessage.fromMap(
                    doc.id,
                    doc.data(),
                    isPending: doc.metadata.hasPendingWrites,
                  ),
                ),
              );
              emit();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await reportSub?.cancel();
        await messagesSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> send({required String text, required ReportType type}) async {
    final report = _report;
    if (report == null) throw const ChatUnavailableException();

    final batch = _firestore.batch();
    batch.set(report.collection('messages').doc(), {
      'senderRole': ChatSender.student.name,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (_status == null) {
      // Primeira mensagem: cria o relato que a psicóloga vê na triagem.
      batch.set(report, {
        'studentUid': report.id,
        'type': type.name,
        'description': text,
        'status': ReportStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if (_status == ReportStatus.answered) {
      // O aluno voltou a escrever: o relato volta para a fila da triagem.
      batch.update(report, {'status': ReportStatus.pending.name});
    }

    try {
      await batch.commit().timeout(queueTimeout);
    } on TimeoutException {
      // Sem internet: a escrita está na fila local do Firestore.
    }
  }
}
