import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/models/chat_message.dart';
import 'package:mente_leve/modules/student/chat/repositories/chat_repository.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/utils/firestore_error_messages.dart';
import 'package:mente_leve/shared/widgets/chat/chat_widgets.dart';

/// Controlador do chat anônimo do aluno com a escola (RF05).
///
/// Assina a conversa em tempo real: as mensagens da psicóloga aparecem assim
/// que chegam, sem o aluno precisar recarregar a tela.
class AnonymousChatController extends ChangeNotifier {
  AnonymousChatController({ChatRepository? repository})
    : _repository = repository ?? defaultRepository ?? InMemoryChatRepository();

  /// Repositório padrão injetado no bootstrap (`main.dart`).
  static ChatRepository? defaultRepository;

  /// Limite de caracteres de uma mensagem (regra do Firestore).
  static const maxMessageLength = chatMaxMessageLength;

  final ChatRepository _repository;
  StreamSubscription<ChatThread>? _subscription;

  ChatThread _thread = ChatThread.empty;
  ReportType? _selectedType;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  String? _loadError;
  bool _disposed = false;

  List<ChatMessage> get messages => _thread.messages;
  ReportStatus? get status => _thread.status;

  /// Assunto escolhido pelo aluno (`null` até ele escolher). Não há assunto
  /// pré-selecionado: o aluno precisa apontar sobre o que quer falar.
  ReportType? get selectedType => _selectedType;

  /// `true` até a primeira resposta do repositório.
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  /// Falha ao enviar a última mensagem.
  String? get errorMessage => _errorMessage;

  /// Falha ao acompanhar a conversa em tempo real.
  String? get loadError => _loadError;

  /// Sem login no Firebase não há como enviar.
  bool get canSend => _repository.isAvailable;

  /// O assunto do relato só é escolhido antes da primeira mensagem.
  bool get canChooseType => messages.isEmpty;

  /// `true` enquanto falta o aluno escolher o assunto para poder enviar.
  bool get needsSubject => canChooseType && _selectedType == null;

  /// Começa (ou recomeça, após um erro) a acompanhar a conversa.
  void start() {
    _subscription?.cancel();
    _loadError = null;
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.watch().listen(
      (thread) {
        _thread = thread;
        _isLoading = false;
        _loadError = null;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Chat anônimo: falha ao acompanhar a conversa: $error');
        _isLoading = false;
        _loadError = chatLoadErrorMessage(error);
        notifyListeners();
      },
    );
  }

  void selectType(ReportType type) {
    if (!canChooseType || _selectedType == type) return;
    _selectedType = type;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Envia [raw] como mensagem do aluno. Devolve `true` quando a mensagem foi
  /// aceita (enviada ou na fila offline) e o campo de texto pode ser limpo.
  Future<bool> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _isSending) return false;
    if (text.length > maxMessageLength) {
      _errorMessage = 'A mensagem pode ter até $maxMessageLength caracteres.';
      notifyListeners();
      return false;
    }

    if (needsSubject) {
      _errorMessage = 'Escolha o assunto da conversa antes de enviar.';
      notifyListeners();
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Depois da primeira mensagem o assunto já está no relato.
      await _repository.send(
        text: text,
        type: _selectedType ?? ReportType.other,
      );
      return true;
    } on ChatUnavailableException {
      _errorMessage =
          'Sem conexão com a escola. Conecte-se à internet para enviar.';
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível enviar a mensagem. Tente novamente.';
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
