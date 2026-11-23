import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/models/guide_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/guides/guide_card.dart';

/// Argumentos para abrir a tela de leitura completa de um guia.
class GuideDetailArgs {
  const GuideDetailArgs({required this.guide, this.colorIndex = 0});

  final GuideModel guide;
  final int colorIndex;
}

/// Tela de leitura completa de um Guia e Orientação aberto pela Home dos
/// responsáveis (RF11).
class GuideDetailView extends StatelessWidget {
  const GuideDetailView({
    super.key,
    required this.guide,
    this.colorIndex = 0,
  });

  static const routeName = '/parents/guide';

  static Future<void> open(
    BuildContext context, {
    required GuideModel guide,
    int colorIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => GuideDetailView(guide: guide, colorIndex: colorIndex),
      ),
    );
  }

  final GuideModel guide;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final banner = GuideBannerStyle.forIndex(colorIndex);

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('guide_detail_back_button'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Voltar',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: AppColors.zinc950,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Orientações',
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
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE4E4E7)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: banner.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.78),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(banner.icon, size: 28, color: banner.accent),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      guide.displayCategory.toUpperCase(),
                      key: const Key('guide_detail_category'),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.sky700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      guide.title,
                      key: const Key('guide_detail_title'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                      ),
                      child: Text(
                        guide.description,
                        key: const Key('guide_detail_description'),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: AppColors.slate600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      guide.text,
                      key: const Key('guide_detail_text'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.65,
                        color: AppColors.zinc950,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
