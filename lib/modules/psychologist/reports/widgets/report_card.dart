import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

/// Par de cores (fundo e texto) de um selo do painel de triagem.
/// Todos os pares têm contraste mínimo de 4,5:1 (WCAG AA).
class BadgeColors {
  const BadgeColors(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static BadgeColors forSeverity(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.high:
        return const BadgeColors(Color(0xFFFFE2E2), Color(0xFF9F0712));
      case ReportSeverity.medium:
        return const BadgeColors(Color(0xFFFFEDD4), Color(0xFF9F2D00));
      case ReportSeverity.low:
        return const BadgeColors(Color(0xFFF1F5F9), AppColors.slate600);
    }
  }

  static BadgeColors forStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return const BadgeColors(Color(0xFFFEF3C7), Color(0xFF92400E));
      case ReportStatus.inMediation:
        return const BadgeColors(Color(0xFFDFF2FE), Color(0xFF00598A));
      case ReportStatus.answered:
        return const BadgeColors(Color(0xFFDCFCE7), Color(0xFF116932));
    }
  }
}

String formatReportDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} às '
      '${two(date.hour)}:${two(date.minute)}';
}

class ReportBadge extends StatelessWidget {
  const ReportBadge({
    super.key,
    required this.label,
    required this.colors,
    this.semanticsPrefix,
  });

  final String label;
  final BadgeColors colors;

  /// Prefixo lido por leitores de tela ("Gravidade", "Status").
  final String? semanticsPrefix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsPrefix == null ? label : '$semanticsPrefix: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}

/// Card de um relato anônimo na triagem (protótipo: "Mensagem anônima #010").
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.protocol,
    required this.onOpen,
    this.compact = false,
  });

  final Report report;
  final String protocol;
  final VoidCallback onOpen;

  /// Versão do resumo da Home: sem data e com o texto em duas linhas.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('report_card_${report.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mensagem anônima $protocol',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.zinc950,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
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
                colors: const BadgeColors(
                  Color(0xFFF4F4F5),
                  AppColors.zinc900,
                ),
                semanticsPrefix: 'Tipo',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.description,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.4,
              color: AppColors.zinc950,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              formatReportDate(report.createdAt),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.slate600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              key: Key('report_open_${report.id}'),
              onPressed: onOpen,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sky700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Ver relato',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Folha com o relato completo (sem nenhum dado que identifique o aluno).
Future<void> showReportDetail(
  BuildContext context, {
  required Report report,
  required String protocol,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (sheetContext) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              key: const Key('report_detail_sheet'),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mensagem anônima $protocol',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc950,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recebida em ${formatReportDate(report.createdAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ReportBadge(
                        label: report.status.label,
                        colors: BadgeColors.forStatus(report.status),
                        semanticsPrefix: 'Status',
                      ),
                      ReportBadge(
                        label:
                            'Gravidade ${report.severity.label.toLowerCase()}',
                        colors: BadgeColors.forSeverity(report.severity),
                      ),
                      ReportBadge(
                        label: report.type.label,
                        colors: const BadgeColors(
                          Color(0xFFF4F4F5),
                          AppColors.zinc900,
                        ),
                        semanticsPrefix: 'Tipo',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    report.description,
                    key: const Key('report_detail_text'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.zinc950,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      key: const Key('report_detail_close'),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sky700,
                        side: const BorderSide(color: AppColors.sky700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Fechar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
