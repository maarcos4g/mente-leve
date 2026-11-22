import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_controller.dart';
import 'package:mente_leve/shared/widgets/chat/chat_widgets.dart';

/// Argumentos da rota do chat da psicóloga.
class ReportChatArgs {
  const ReportChatArgs({required this.reportId, required this.protocol});

  final String reportId;

  /// Número exibido no lugar de qualquer identificação ("#003").
  final String protocol;
}

/// Chat da psicóloga com o aluno de um relato anônimo (RF10), em tempo real.
///
/// Mostra a conversa inteira e deixa responder. Nada na tela identifica o
/// aluno.
class PsychologistChatView extends StatefulWidget {
  const PsychologistChatView({
    super.key,
    required this.args,
    this.controller,
    this.now,
  });

  static const routeName = '/psychologist/chat';

  /// Abre o chat do relato [reportId] pela rota nomeada.
  static Future<void> open(
    BuildContext context, {
    required String reportId,
    required String protocol,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: ReportChatArgs(reportId: reportId, protocol: protocol),
    );
  }

  final ReportChatArgs args;
  final PsychologistChatController? controller;

  /// Relógio (testes): define o que é "Hoje" e "Ontem".
  final DateTime Function()? now;

  @override
  State<PsychologistChatView> createState() => _PsychologistChatViewState();
}

class _PsychologistChatViewState extends State<PsychologistChatView> {
  late final PsychologistChatController _controller;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        PsychologistChatController(reportId: widget.args.reportId);
    _controller.addListener(_onChanged);
    _controller.start();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    final count = _controller.messages.length;
    if (count != _lastMessageCount) {
      _lastMessageCount = count;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  void _scrollToEnd() {
    if (!mounted || !_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _showError() {
    final message = _controller.errorMessage;
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    final accepted = await _controller.send(text);
    if (!mounted) return;
    if (accepted) {
      _input.clear();
    } else {
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChatAppBar(
              title: 'Chat',
              subtitle: 'Mensagem anônima ${widget.args.protocol}',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const Divider(height: 1, color: Color(0xFFE4E4E7)),
            Expanded(child: _buildBody()),
            if (!_controller.isLoading &&
                _controller.loadError == null &&
                !_controller.notFound)
              ChatComposer(
                textController: _input,
                enabled: true,
                isSending: _controller.isSending,
                onSend: _send,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.loadError != null) {
      return ChatCenteredMessage(
        key: const Key('chat_load_error'),
        icon: LucideIcons.triangleAlert,
        message: _controller.loadError!,
        actionKey: const Key('chat_retry_button'),
        actionLabel: 'Tentar novamente',
        onAction: _controller.start,
      );
    }
    if (_controller.notFound) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Este relato não foi encontrado.',
            key: Key('psychologist_chat_not_found'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      key: const Key('chat_messages_list'),
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      children: chatMessageItems(
        messages: _controller.messages,
        now: _now,
        isOwn: (message) => !message.isFromStudent,
        otherLabel: 'Aluno anônimo',
      ),
    );
  }
}
