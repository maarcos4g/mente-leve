import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/chat/anonymous_chat_controller.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/chat/chat_widgets.dart';

/// Chat anônimo do aluno com a escola (RF05). Funciona em tempo real: as
/// respostas da psicóloga aparecem na hora, e as mensagens escritas sem
/// internet ficam como "Enviando…" até o Firestore sincronizar.
class AnonymousChatView extends StatefulWidget {
  const AnonymousChatView({super.key, this.controller, this.now});

  /// Mesma rota da Home e do modal de apoio (`HomeController.reportRoute`).
  static const routeName = '/report';

  /// O botão "Ajuda (CVV)" fica sobre o canto inferior direito; o campo de
  /// mensagem sobe esta altura para não ficar escondido atrás dele.
  static const cvvClearance = 96.0;

  final AnonymousChatController? controller;

  /// Relógio (testes): define o que é "Hoje" e "Ontem".
  final DateTime Function()? now;

  @override
  State<AnonymousChatView> createState() => _AnonymousChatViewState();
}

class _AnonymousChatViewState extends State<AnonymousChatView> {
  late final AnonymousChatController _controller;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AnonymousChatController();
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

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    final accepted = await _controller.send(text);
    if (!mounted) return;
    if (accepted) {
      _input.clear();
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
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
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const Divider(height: 1, color: Color(0xFFE4E4E7)),
            Expanded(child: _buildBody()),
            ChatComposer(
              textController: _input,
              enabled: _controller.canSend,
              isSending: _controller.isSending,
              onSend: _send,
              bottomInset: AnonymousChatView.cvvClearance,
              banner:
                  _controller.canSend
                      ? null
                      : 'Você está sem conexão com a escola. Conecte-se à '
                          'internet para enviar mensagens.',
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

    return ListView(
      key: const Key('chat_messages_list'),
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      children: [
        if (_controller.canChooseType)
          _IntroCard(
            selected: _controller.selectedType,
            onSelected: _controller.selectType,
          ),
        ...chatMessageItems(
          messages: _controller.messages,
          now: _now,
          isOwn: (message) => message.isFromStudent,
          otherLabel: 'Psicóloga',
        ),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.selected, required this.onSelected});

  final ReportType? selected;
  final ValueChanged<ReportType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('chat_empty_intro'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChatColors.otherBubble,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                size: 20,
                color: ChatColors.otherText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conversa anônima',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ChatColors.otherText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Aqui você pode contar o que está acontecendo. A escola não vê '
            'seu nome e a psicóloga responde por aqui.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.4,
              color: ChatColors.otherText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sobre o que você quer falar? Escolha um assunto para enviar.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ChatColors.otherText,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final type in ReportType.values)
                ChoiceChip(
                  key: Key('chat_type_${type.name}'),
                  label: Text(
                    type.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          selected == type ? Colors.white : AppColors.zinc950,
                    ),
                  ),
                  selected: selected == type,
                  onSelected: (_) => onSelected(type),
                  showCheckmark: false,
                  selectedColor: ChatColors.ownBubble,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color:
                        selected == type
                            ? ChatColors.ownBubble
                            : const Color(0xFFD4D4D8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
