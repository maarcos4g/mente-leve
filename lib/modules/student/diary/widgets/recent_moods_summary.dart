import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Exibe o "Resumo da semana" com o histórico dos últimos humores registrados
/// localmente no aparelho (RF01 / RF06 / RNF03).
class RecentMoodsSummary extends StatelessWidget {
  final DiaryController controller;

  const RecentMoodsSummary({
    super.key,
    required this.controller,
  });

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isYesterday = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.subtract(const Duration(days: 1)).day;

    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Hoje às $hour:$minute';
    } else if (isYesterday) {
      return 'Ontem às $hour:$minute';
    } else {
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month às $hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.entries;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TailwindColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TailwindColors.zinc200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: TailwindColors.zinc100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.home,
                          size: 16,
                          color: TailwindColors.zinc700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Resumo da semana',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TailwindColors.zinc900,
                        ),
                      ),
                    ],
                  ),
                  if (entries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: TailwindColors.sky50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TailwindColors.sky200),
                      ),
                      child: Text(
                        '${entries.length} ${entries.length == 1 ? 'registro' : 'registros'}',
                        style: AppTextStyles.textXs.copyWith(
                          color: TailwindColors.sky700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (entries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: TailwindColors.zinc50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TailwindColors.zinc200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🌱',
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum registro ainda',
                        style: AppTextStyles.captionMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TailwindColors.zinc800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toque em um emoji acima para registrar como você está se sentindo hoje.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.textXs.copyWith(
                          color: TailwindColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length > 5 ? 5 : entries.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 16,
                    thickness: 0.8,
                    color: TailwindColors.zinc100,
                  ),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    return _HistoryItemRow(
                      registro: item,
                      formattedDate: _formatDateTime(item.dataHora),
                      onDelete: () => controller.deleteEntry(item.id),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryItemRow extends StatelessWidget {
  final RegistroDiario registro;
  final String formattedDate;
  final VoidCallback onDelete;

  const _HistoryItemRow({
    required this.registro,
    required this.formattedDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final humor = registro.humor;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: humor.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: humor.color.withValues(alpha: 0.3)),
          ),
          child: Text(
            humor.emoji,
            style: const TextStyle(fontSize: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                humor.label,
                style: AppTextStyles.captionMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TailwindColors.zinc900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: AppTextStyles.textXs.copyWith(
                  color: TailwindColors.zinc500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 18,
            color: TailwindColors.zinc400,
          ),
          tooltip: 'Excluir registro',
          onPressed: onDelete,
        ),
      ],
    );
  }
}
