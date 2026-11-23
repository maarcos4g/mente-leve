import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_view.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_controller.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_view.dart';
import 'package:mente_leve/modules/psychologist/reports/widgets/report_card.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

/// Card "Triagem das denúncias" da Home da psicóloga: mostra os relatos
/// pendentes mais urgentes e leva ao painel completo.
class ReportsSummaryCard extends StatefulWidget {
  const ReportsSummaryCard({super.key, this.controller});

  final ReportsController? controller;

  @override
  State<ReportsSummaryCard> createState() => _ReportsSummaryCardState();
}

class _ReportsSummaryCardState extends State<ReportsSummaryCard> {
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

  // O resumo acompanha os relatos em tempo real; não precisa recarregar ao voltar.
  void _openPanel() => Navigator.of(context).pushNamed(ReportsView.routeName);

  @override
  Widget build(BuildContext context) {
    final pending = _controller.pendingForTriage();

    return Container(
      key: const Key('reports_summary_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.inbox, size: 20, color: AppColors.zinc950),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Triagem das denúncias',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.zinc950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_controller.isLoading && !_controller.hasLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_controller.errorMessage != null)
            Text(
              _controller.errorMessage!,
              key: const Key('reports_summary_error'),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.slate600,
              ),
            )
          else if (pending.isEmpty)
            Text(
              'Nenhuma denúncia pendente.',
              key: const Key('reports_summary_empty'),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.slate600,
              ),
            )
          else
            for (final report in pending) ...[
              ReportCard(
                report: report,
                protocol: _controller.protocol(report),
                compact: true,
                onOpen:
                    () => PsychologistChatView.open(
                      context,
                      reportId: report.id,
                      protocol: _controller.protocol(report),
                    ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              key: const Key('psychologist_open_reports_button'),
              onPressed: _openPanel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sky700,
                side: const BorderSide(color: AppColors.sky700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Ver todas as denúncias',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
