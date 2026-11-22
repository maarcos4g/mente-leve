import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/shared/models/report_model.dart';

/// Conversa de um relato vista pela psicóloga: o relato (`null` se o
/// documento não existe) e as mensagens em ordem de envio.
class ReportConversation {
  const ReportConversation({this.report, this.messages = const []});

  final Report? report;
  final List<ChatMessage> messages;
}

/// Contrato do chat da psicóloga com o aluno que fez o relato (RF10).
abstract class PsychologistChatRepository {
  /// Conversa em tempo real: emite a cada mensagem nova do aluno e a cada
  /// mudança de status ou gravidade do relato.
  Stream<ReportConversation> watch(String reportId);

  /// Responde ao aluno. A primeira resposta de um relato pendente muda o
  /// status para `answered`; um relato em mediação continua em mediação.
  Future<void> reply({required String reportId, required String text});

  Future<void> setStatus(String reportId, ReportStatus status);

  Future<void> setSeverity(String reportId, ReportSeverity severity);
}

/// Repositório em memória, usado nos testes e quando o Firestore não foi
/// injetado no bootstrap.
class InMemoryPsychologistChatRepository implements PsychologistChatRepository {
  InMemoryPsychologistChatRepository(
    this._report, {
    List<ChatMessage>? messages,
  }) : _messages = List<ChatMessage>.from(messages ?? const []);

  Report _report;
  final List<ChatMessage> _messages;
  final StreamController<ReportConversation> _controller =
      StreamController<ReportConversation>.broadcast();
  int _counter = 0;

  ReportConversation get _conversation => ReportConversation(
    report: _report,
    messages: List.unmodifiable(_messages),
  );

  @override
  Stream<ReportConversation> watch(String reportId) async* {
    yield _conversation;
    yield* _controller.stream;
  }

  /// Simula uma mensagem do aluno chegando em tempo real.
  void studentSays(String text) {
    _add(ChatSender.student, text);
    if (_report.status == ReportStatus.answered) {
      _report = _copy(status: ReportStatus.pending);
    }
    _controller.add(_conversation);
  }

  @override
  Future<void> reply({required String reportId, required String text}) async {
    _add(ChatSender.psychologist, text);
    if (_report.status == ReportStatus.pending) {
      _report = _copy(status: ReportStatus.answered);
    }
    _controller.add(_conversation);
  }

  @override
  Future<void> setStatus(String reportId, ReportStatus status) async {
    _report = _copy(status: status);
    _controller.add(_conversation);
  }

  @override
  Future<void> setSeverity(String reportId, ReportSeverity severity) async {
    _report = _copy(severity: severity);
    _controller.add(_conversation);
  }

  Report _copy({ReportStatus? status, ReportSeverity? severity}) => Report(
    id: _report.id,
    type: _report.type,
    description: _report.description,
    status: status ?? _report.status,
    createdAt: _report.createdAt,
    severity: severity ?? _report.severity,
  );

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
  }
}

/// Chat da psicóloga sobre o Cloud Firestore, em tempo real.
///
/// Lê `reports/{id}` e `reports/{id}/messages`. A resposta grava a mensagem
/// com `senderRole: psychologist` e, no mesmo lote, atualiza o status do
/// relato. Não grava nenhum dado da psicóloga na mensagem.
class FirestorePsychologistChatRepository
    implements PsychologistChatRepository {
  FirestorePsychologistChatRepository(
    this._firestore, {
    this.queueTimeout = const Duration(seconds: 3),
  });

  final FirebaseFirestore _firestore;

  /// Sem rede o `commit` só termina quando o servidor responde. Passado este
  /// prazo a escrita é tratada como "na fila" e a tela segue em frente.
  final Duration queueTimeout;

  final Map<String, ReportStatus> _statuses = {};

  DocumentReference<Map<String, dynamic>> _report(String id) =>
      _firestore.collection('reports').doc(id);

  @override
  Stream<ReportConversation> watch(String reportId) {
    final report = _report(reportId);

    late final StreamController<ReportConversation> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? reportSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? messagesSub;
    Report? current;
    var messages = const <ChatMessage>[];

    void emit() {
      if (!controller.isClosed) {
        controller.add(ReportConversation(report: current, messages: messages));
      }
    }

    controller = StreamController<ReportConversation>(
      onListen: () {
        reportSub = report
            .snapshots(includeMetadataChanges: true)
            .listen((snap) {
              final data = snap.data();
              current = snap.exists && data != null
                  ? Report.fromMap(snap.id, data)
                  : null;
              if (current != null) _statuses[reportId] = current!.status;
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
  Future<void> reply({required String reportId, required String text}) {
    final report = _report(reportId);
    final batch = _firestore.batch();
    batch.set(report.collection('messages').doc(), {
      'senderRole': ChatSender.psychologist.name,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (_statuses[reportId] == ReportStatus.pending) {
      batch.update(report, {'status': ReportStatus.answered.name});
    }
    return _commit(batch);
  }

  @override
  Future<void> setStatus(String reportId, ReportStatus status) {
    final batch = _firestore.batch()
      ..update(_report(reportId), {'status': status.name});
    return _commit(batch);
  }

  @override
  Future<void> setSeverity(String reportId, ReportSeverity severity) {
    final batch = _firestore.batch()
      ..update(_report(reportId), {'severity': severity.name});
    return _commit(batch);
  }

  Future<void> _commit(WriteBatch batch) async {
    try {
      await batch.commit().timeout(queueTimeout);
    } on TimeoutException {
      // Sem internet: a escrita está na fila local do Firestore.
    }
  }
}
