import 'package:flutter/material.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Botão de seleção rápida de humor com emoji grande (RF01 / RNF08).
///
/// Atende às diretrizes de acessibilidade e design system:
/// - Área de toque mínima garantida de 48x48dp (WCAG AA).
/// - Feedback visual com paleta suave Tailwind e formas arredondadas.
/// - Suporte a leitores de tela via Semantics.
class EmojiButton extends StatelessWidget {
  final Humor humor;
  final bool isSelected;
  final VoidCallback onTap;

  const EmojiButton({
    super.key,
    required this.humor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Humor ${humor.label}',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            constraints: const BoxConstraints(
              minWidth: 54,
              minHeight: 72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? humor.backgroundColor : TailwindColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? humor.color : TailwindColors.zinc200,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: humor.color.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  humor.emoji,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    humor.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppTextStyles.textXs.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? humor.color : TailwindColors.zinc700,
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
}
