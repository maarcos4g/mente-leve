import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_view.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_controller.dart';
import 'package:mente_leve/modules/psychologist/reports/widgets/report_card.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

/// Painel de Gestão e Triagem de Relatos Anônimos da psicóloga
/// (RF09 / EPIC-06): lista as denúncias recebidas, com filtros de gravidade
/// e de status de mediação.
class ReportsView extends StatefulWidget {
  const ReportsView({super.key, this.controller});

  final ReportsController? controller;

  static const routeName = '/psychologist/reports';

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  late final ReportsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ReportsController();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = _controller.sorted;

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReportsAppBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.load,
                child: ListView(
                  key: const Key('reports_list'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    Text(
                      'Relatos anônimos',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe e priorize os relatos enviados pelos alunos',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildBody(reports),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(List<Report> reports) {
    if (_controller.isLoading && !_controller.hasLoaded) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_controller.errorMessage != null) {
      return [
        _StateMessage(
          key: const Key('reports_error'),
          icon: LucideIcons.triangleAlert,
          message: _controller.errorMessage!,
          actionKey: const Key('reports_retry_button'),
          actionLabel: 'Tentar novamente',
          onAction: _controller.load,
        ),
      ];
    }
    if (_controller.total == 0) {
      return const [
        _StateMessage(
          key: Key('reports_empty'),
          icon: LucideIcons.inbox,
          message: 'Nenhuma denúncia recebida até agora.',
        ),
      ];
    }
    return [
      Text(
        key: const Key('reports_counter'),
        '${_controller.total} '
        '${_controller.total == 1 ? 'relato' : 'relatos'} '
        '(${_controller.pendingCount} '
        '${_controller.pendingCount == 1 ? 'pendente' : 'pendentes'})',
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.slate600),
      ),
      const SizedBox(height: 10),
      for (final report in reports) ...[
        ReportCard(
          report: report,
          protocol: _controller.protocol(report),
          onOpen:
              () => PsychologistChatView.open(
                context,
                reportId: report.id,
                protocol: _controller.protocol(report),
              ),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    super.key,
    required this.icon,
    required this.message,
    this.actionKey,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.slate600),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.slate600,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              key: actionKey,
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: AppColors.sky700,
              ),
              child: Text(
                actionLabel ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportsAppBar extends StatelessWidget {
  const _ReportsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('reports_back_button'),
            onPressed: onBack,
            tooltip: 'Voltar',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 24,
              color: AppColors.zinc950,
            ),
          ),
          Expanded(
            child: Text(
              'Triagem de Denúncias',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc950,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
