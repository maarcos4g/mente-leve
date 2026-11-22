import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mente_leve/shared/models/report_model.dart';

/// Quem escreveu a mensagem do chat anônimo.
enum ChatSender {
  student,
  psychologist;

  static ChatSender fromName(String? name) {
    // Valor desconhecido nunca é tratado como mensagem do próprio aluno.
    return name == ChatSender.student.name
        ? ChatSender.student
        : ChatSender.psychologist;
  }
}

/// Mensagem de `reports/{uid}/messages/{messageId}`.
///
/// Não guarda nome nem qualquer dado que identifique o aluno.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime createdAt;

  /// `true` enquanto o Firestore ainda não confirmou o envio (sem internet,
  /// por exemplo). Nunca é gravado.
  final bool isPending;

  bool get isFromStudent => sender == ChatSender.student;

  factory ChatMessage.fromMap(
    String id,
    Map<String, dynamic> data, {
    bool isPending = false,
  }) {
    final rawCreatedAt = data['createdAt'];
    return ChatMessage(
      id: id,
      sender: ChatSender.fromName(data['senderRole'] as String?),
      text: (data['text'] as String?) ?? '',
      // Enquanto o servidor não confirma o horário, o campo vem nulo.
      createdAt:
          rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : DateTime.now(),
      isPending: isPending,
    );
  }
}

/// Estado da conversa do aluno: mensagens em ordem de envio e o status do
/// relato (`null` enquanto o aluno ainda não enviou a primeira mensagem).
class ChatThread {
  const ChatThread({this.messages = const [], this.status});

  static const empty = ChatThread();

  final List<ChatMessage> messages;
  final ReportStatus? status;
}
