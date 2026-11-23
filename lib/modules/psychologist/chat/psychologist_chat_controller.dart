import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mente_leve/modules/psychologist/chat/repositories/psychologist_chat_repository.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/utils/firestore_error_messages.dart';
import 'package:mente_leve/shared/widgets/chat/chat_widgets.dart';

/// Controlador do chat da psicóloga com o aluno de um relato (RF10).
///
/// Acompanha a conversa em tempo real e envia as respostas.
class PsychologistChatController extends ChangeNotifier {
  PsychologistChatController({
    required this.reportId,
    PsychologistChatRepository? repository,
  }) : _repository = repository ?? defaultRepository;

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static PsychologistChatRepository? defaultRepository;

  static const maxMessageLength = chatMaxMessageLength;

  final String reportId;
  final PsychologistChatRepository? _repository;
  StreamSubscription<ReportConversation>? _subscription;

  ReportConversation _conversation = const ReportConversation();
  bool _isLoading = true;
  bool _isSending = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _loadError;

  Report? get report => _conversation.report;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get loadError => _loadError;

  /// `true` quando a conversa carregou e o relato não existe mais.
  bool get notFound => !_isLoading && _loadError == null && report == null;

  /// Mensagens da conversa. Relatos sem mensagens (criados direto no console)
  /// mostram o texto do relato como a primeira mensagem do aluno.
  List<ChatMessage> get messages {
    final stored = _conversation.messages;
    final current = report;
    if (stored.isNotEmpty || current == null) return stored;
    return [
      ChatMessage(
        id: 'description',
        sender: ChatSender.student,
        text: current.description,
        createdAt: current.createdAt,
      ),
    ];
  }

  PsychologistChatRepository get _repo {
    final repo = _repository;
    if (repo == null) {
      throw StateError('PsychologistChatController sem repositório injetado');
    }
    return repo;
  }

  /// Começa (ou recomeça, após um erro) a acompanhar a conversa.
  void start() {
    _subscription?.cancel();
    _loadError = null;
    _isLoading = true;
    notifyListeners();
    _subscription = _repo
        .watch(reportId)
        .listen(
          (conversation) {
            _conversation = conversation;
            _isLoading = false;
            _loadError = null;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Chat da psicóloga: falha ao acompanhar: $error');
            _isLoading = false;
            _loadError = chatLoadErrorMessage(error);
            notifyListeners();
          },
        );
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Envia [raw] como resposta. Devolve `true` quando a mensagem foi aceita
  /// (enviada ou na fila offline) e o campo de texto pode ser limpo.
  Future<bool> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _isSending) return false;
    if (text.length > maxMessageLength) {
      _errorMessage = 'A mensagem pode ter até $maxMessageLength caracteres.';
      notifyListeners();
      return false;
    }
    _isSending = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repo.reply(reportId: reportId, text: text);
      return true;
    } catch (error) {
      debugPrint('Chat da psicóloga: falha ao enviar: $error');
      _errorMessage = 'Não foi possível enviar a resposta. Tente novamente.';
      return false;
    } finally {
      _isSending = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
