import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';

/// Card de atalho da Home: título à esquerda e ilustração ancorada embaixo.
class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    super.key,
    required this.illustrationAsset,
    required this.illustrationSize,
    required this.illustrationOffset,
    required this.onTap,
    this.title,
    this.titleWidget,
    this.semanticLabel,
  }) : assert(
         (title != null) != (titleWidget != null),
         'Informe title ou titleWidget',
       );

  final String? title;

  /// Título com posicionamento próprio (card de FAQ).
  final Widget? titleWidget;
  final String illustrationAsset;
  final Size illustrationSize;

  /// Posição da ilustração a partir do canto superior esquerdo do card.
  final Offset illustrationOffset;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? title?.replaceAll('\n', ' '),
      excludeSemantics: true,
      child: Material(
        color: AppColors.zinc100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.sky700),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 171,
            child: Stack(
              children: [
                Positioned(
                  left: illustrationOffset.dx,
                  top: illustrationOffset.dy,
                  width: illustrationSize.width,
                  height: illustrationSize.height,
                  child: SvgPicture.asset(
                    illustrationAsset,
                    width: illustrationSize.width,
                    height: illustrationSize.height,
                  ),
                ),
                if (title != null)
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Text(
                      title!,
                      style: AppTextStyles.buttonHeading.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ?titleWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
