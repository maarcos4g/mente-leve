import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_controller.dart';
import 'package:mente_leve/modules/psychologist/reports/widgets/report_card.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
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
/// Mostra a conversa inteira, deixa responder e gerenciar o status de
/// mediação e a gravidade do relato. Nada na tela identifica o aluno.
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

  Future<void> _changeStatus(ReportStatus status) async {
    final ok = await _controller.setStatus(status);
    if (mounted && !ok) _showError();
  }

  Future<void> _changeSeverity(ReportSeverity severity) async {
    final ok = await _controller.setSeverity(severity);
    if (mounted && !ok) _showError();
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
            if (_controller.report != null)
              _ManagePanel(
                report: _controller.report!,
                onStatus: _changeStatus,
                onSeverity: _changeSeverity,
              ),
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

/// Resumo do relato e controles de status de mediação e gravidade.
class _ManagePanel extends StatelessWidget {
  const _ManagePanel({
    required this.report,
    required this.onStatus,
    required this.onSeverity,
  });

  final Report report;
  final ValueChanged<ReportStatus> onStatus;
  final ValueChanged<ReportSeverity> onSeverity;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: const Key('psychologist_chat_manage'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ReportBadge(
              label: report.status.label,
              colors: BadgeColors.forStatus(report.status),
              semanticsPrefix: 'Status',
            ),
            ReportBadge(
              label: 'Gravidade ${report.severity.label.toLowerCase()}',
              colors: BadgeColors.forSeverity(report.severity),
            ),
            ReportBadge(
              label: report.type.label,
              colors: const BadgeColors(Color(0xFFF4F4F5), AppColors.zinc900),
              semanticsPrefix: 'Tipo',
            ),
          ],
        ),
        subtitle: Text(
          'Gerenciar relato',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate600),
        ),
        children: [
          _ChipGroup<ReportStatus>(
            keyPrefix: 'psychologist_chat_status',
            title: 'Status de mediação',
            values: ReportStatus.values,
            labelOf: (s) => s.label,
            selected: report.status,
            onSelected: onStatus,
          ),
          const SizedBox(height: 8),
          _ChipGroup<ReportSeverity>(
            keyPrefix: 'psychologist_chat_severity',
            title: 'Gravidade',
            values: ReportSeverity.values.reversed.toList(),
            labelOf: (s) => s.label,
            selected: report.severity,
            onSelected: onSeverity,
          ),
        ],
      ),
    );
  }
}

class _ChipGroup<T extends Enum> extends StatelessWidget {
  const _ChipGroup({
    required this.keyPrefix,
    required this.title,
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
  });

  final String keyPrefix;
  final String title;
  final List<T> values;
  final String Function(T) labelOf;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.zinc950,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final value in values)
              ChoiceChip(
                key: Key('${keyPrefix}_${value.name}'),
                label: Text(
                  labelOf(value),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        selected == value ? Colors.white : AppColors.zinc950,
                  ),
                ),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
                showCheckmark: false,
                selectedColor: AppColors.sky700,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color:
                      selected == value
                          ? AppColors.sky700
                          : const Color(0xFFD4D4D8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
