import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/models/faq_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';

/// Card expansível de pergunta e resposta do FAQ fiel ao protótipo do Figma
/// (RF04, RF08), com contraste WCAG AA e área mínima de toque de 48x48dp.
class FaqExpandableCard extends StatelessWidget {
  const FaqExpandableCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onToggle,
  });

  final FaqModel item;
  final bool isExpanded;
  final VoidCallback onToggle;

  static const Color collapsedBackground = AppColors.zinc100;
  static const Color expandedBackground = Color(0xFFDFF2FE);
  static const Color expandedTextColor = Color(0xFF00598A);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: isExpanded,
      label: item.question,
      child: Material(
        color: isExpanded ? expandedBackground : collapsedBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isExpanded ? AppColors.sky700 : AppColors.zinc900,
            width: isExpanded ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('faq_card_${item.id}'),
          onTap: onToggle,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight:
                                isExpanded ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isExpanded
                                    ? expandedTextColor
                                    : AppColors.zinc950,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 20,
                        color:
                            isExpanded
                                ? expandedTextColor
                                : AppColors.zinc950,
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.answer,
                      key: Key('faq_answer_${item.id}'),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        color: expandedTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
