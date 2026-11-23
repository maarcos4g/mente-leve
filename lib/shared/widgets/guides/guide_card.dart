import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/models/guide_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

/// Paleta pastel dos banners superiores dos cards de Guias e Orientações,
/// extraída do protótipo do Figma (`sky/100` `#DFF2FE` e `emerald/100` `#D0FAE5`).
class GuideBannerStyle {
  const GuideBannerStyle({
    required this.background,
    required this.accent,
    required this.icon,
  });

  final Color background;
  final Color accent;
  final IconData icon;

  static const List<GuideBannerStyle> palette = [
    GuideBannerStyle(
      background: Color(0xFFDFF2FE),
      accent: AppColors.sky700,
      icon: LucideIcons.heartHandshake,
    ),
    GuideBannerStyle(
      background: Color(0xFFD0FAE5),
      accent: Color(0xFF047857),
      icon: LucideIcons.bookOpen,
    ),
    GuideBannerStyle(
      background: Color(0xFFFEF3C7),
      accent: Color(0xFFB45309),
      icon: LucideIcons.sparkles,
    ),
  ];

  static GuideBannerStyle forIndex(int index) =>
      palette[index % palette.length];
}

/// Card de Guia e Orientação reutilizado na Home dos Responsáveis (`home / parents`)
/// e na tela de gestão da Psicóloga (`guias / edit`).
class GuideCard extends StatelessWidget {
  const GuideCard({
    super.key,
    required this.guide,
    required this.colorIndex,
    this.onTap,
  });

  /// Cores de texto com contraste WCAG AA (>= 4.5:1) sobre [AppColors.zinc100].
  static const Color cardBackground = AppColors.zinc100;
  static const Color categoryTextColor = AppColors.sky700;
  static const Color descriptionTextColor = AppColors.slate600;

  final GuideModel guide;
  final int colorIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final banner = GuideBannerStyle.forIndex(colorIndex);
    final categoryLabel = guide.displayCategory.toUpperCase();

    return Semantics(
      button: onTap != null,
      label: '${guide.title}. ${guide.description}',
      child: Container(
        key: Key('guide_card_${guide.id}'),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(color: banner.background),
                  alignment: Alignment.center,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(banner.icon, size: 24, color: banner.accent),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: categoryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AppColors.zinc950,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: descriptionTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
