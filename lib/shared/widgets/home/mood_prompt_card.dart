import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';

/// Card "Como está sua mente hoje?" que leva ao registro de humor.
class MoodPromptCard extends StatelessWidget {
  const MoodPromptCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentBrown,
            offset: Offset(0, 1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: AppColors.slate600,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.smile,
                  size: 24,
                  color: AppColors.zinc50,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'Como está sua mente hoje?',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: AppColors.zinc50,
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
