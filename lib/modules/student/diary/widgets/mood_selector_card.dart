import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/widgets/emoji_button.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Card principal do Diário de Sentimentos por Emojis (RF01 / RNF05).
///
/// Permite ao aluno selecionar e registrar sua emoção com no máximo 3 interações:
/// 1. Visualizar o card na home
/// 2. Tocar no emoji desejado
/// 3. Clicar em "Salvar humor"
class MoodSelectorCard extends StatelessWidget {
  final DiaryController controller;
  final VoidCallback? onCvvTap;

  const MoodSelectorCard({
    super.key,
    required this.controller,
    this.onCvvTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TailwindColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TailwindColors.zinc200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TailwindColors.sky100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.smile,
                      size: 20,
                      color: TailwindColors.sky700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Como está sua mente hoje?',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: TailwindColors.zinc900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Toque em um emoji para registrar seu humor',
                          style: AppTextStyles.textXs.copyWith(
                            color: TailwindColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Grade de 6 emojis de humor
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    children: Humor.values.map((humor) {
                      final isSelected = controller.selectedHumor == humor;
                      // Calcula largura para acomodar 3 colunas uniformes
                      final itemWidth = (constraints.maxWidth - 16) / 3;
                      return SizedBox(
                        width: itemWidth,
                        child: EmojiButton(
                          humor: humor,
                          isSelected: isSelected,
                          onTap: () => controller.selectHumor(humor),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 18),

              // Botão de salvar (Interação 3)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isReadyToSave
                      ? () => controller.saveHumor()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isReadyToSave
                        ? TailwindColors.sky600
                        : TailwindColors.zinc200,
                    foregroundColor: controller.isReadyToSave
                        ? TailwindColors.white
                        : TailwindColors.zinc400,
                    disabledBackgroundColor: TailwindColors.zinc100,
                    disabledForegroundColor: TailwindColors.zinc400,
                    elevation: controller.isReadyToSave ? 1 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(TailwindColors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.penLine, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              controller.selectedHumor == null
                                  ? 'Selecione um emoji acima'
                                  : 'Salvar ${controller.selectedHumor!.label}',
                              style: AppTextStyles.buttonHeading.copyWith(
                                color: controller.isReadyToSave
                                    ? TailwindColors.white
                                    : TailwindColors.zinc400,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Feedback acolhedor pós-registro
              if (controller.isSaved && controller.feedbackMessage != null) ...[
                const SizedBox(height: 16),
                _FeedbackBanner(
                  humor: controller.selectedHumor,
                  message: controller.feedbackMessage!,
                  onCvvTap: onCvvTap,
                  onReset: controller.resetSelection,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final Humor? humor;
  final String message;
  final VoidCallback? onCvvTap;
  final VoidCallback onReset;

  const _FeedbackBanner({
    required this.humor,
    required this.message,
    required this.onCvvTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = humor?.isCritical ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: humor?.backgroundColor ?? TailwindColors.sky50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: humor?.color.withValues(alpha: 0.3) ?? TailwindColors.sky200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                humor?.emoji ?? '✨',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sentimento registrado!',
                  style: AppTextStyles.captionMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TailwindColors.zinc900,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 16, color: TailwindColors.zinc500),
                onPressed: onReset,
                tooltip: 'Fechar',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTextStyles.captionBody.copyWith(
              color: TailwindColors.zinc700,
              fontSize: 13,
            ),
          ),
          if (isCritical) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: TailwindColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TailwindColors.red200),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.phone, size: 16, color: TailwindColors.sky600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Precisa conversar? O CVV 188 está 24h disponível.',
                      style: AppTextStyles.textXs.copyWith(
                        color: TailwindColors.zinc800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onCvvTap != null)
                    TextButton(
                      onPressed: onCvvTap,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(40, 28),
                      ),
                      child: Text(
                        'Ligar 188',
                        style: AppTextStyles.textXs.copyWith(
                          color: TailwindColors.sky600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
