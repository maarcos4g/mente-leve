import 'package:flutter/material.dart';
import 'package:mente_leve/shared/widgets/home/mood_bubble.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';

/// Bloco "Resumo da semana" com uma bolha de humor por item.
class WeekSummary extends StatelessWidget {
  const WeekSummary({super.key, required this.moods});

  /// Humores exibidos, na ordem do resumo.
  final List<MoodVisual> moods;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo da semana',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.zinc950),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 30 dp entre bolhas no protótipo (390 dp); encolhe em telas
            // estreitas para a linha não estourar.
            final count = moods.length;
            final gap = count > 1
                ? ((constraints.maxWidth - 40 * count) / (count - 1)).clamp(
                    0.0,
                    30.0,
                  )
                : 0.0;
            return SizedBox(
              height: 40,
              child: Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0) SizedBox(width: gap),
                    MoodBubble(mood: moods[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
