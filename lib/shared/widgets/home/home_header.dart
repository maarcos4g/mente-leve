import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';

/// Faixa azul do topo da Home: saudação e avatar do aluno.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.nickname,
    required this.avatarAsset,
    this.onAvatarTap,
  });

  final String nickname;
  final String avatarAsset;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: AppColors.sky500,
      padding: const EdgeInsets.fromLTRB(19, 44, 19, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá,',
                  style: AppTextStyles.titleLight.copyWith(
                    color: AppColors.zinc50,
                  ),
                ),
                Text(
                  '$nickname!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleBoldLine.copyWith(
                    color: AppColors.zinc50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              color: AppColors.zinc50,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onAvatarTap,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(
                    child: SvgPicture.asset(avatarAsset, width: 48, height: 48),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
