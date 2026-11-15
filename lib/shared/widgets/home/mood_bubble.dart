import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Aparência de um humor no resumo: ilustração, cor do brilho e opacidade.
///
/// No Figma cada humor é um cérebro com um brilho (sombra de desfoque 5) na
/// cor do humor. Humores fora de destaque ficam com 30% de opacidade.
class MoodVisual {
  const MoodVisual({
    required this.asset,
    required this.glowColor,
    this.opacity = 0.3,
  });

  final String asset;
  final Color glowColor;
  final double opacity;
}

/// Bolha de 40x40. O SVG tem 60x60 porque inclui a área do brilho.
class MoodBubble extends StatelessWidget {
  const MoodBubble({super.key, required this.mood});

  final MoodVisual mood;

  static const _size = 60.0;
  static const _glowSigma = 5.0;

  @override
  Widget build(BuildContext context) {
    final art = SvgPicture.asset(mood.asset, width: _size, height: _size);
    return SizedBox(
      width: 40,
      height: 40,
      child: OverflowBox(
        minWidth: _size,
        maxWidth: _size,
        minHeight: _size,
        maxHeight: _size,
        // O flutter_svg ignora filtros; o brilho é refeito aqui: silhueta
        // na cor do humor, desfocada, atrás da ilustração. A opacidade vale
        // para o conjunto, como no grupo do Figma.
        child: Opacity(
          opacity: mood.opacity,
          child: Stack(
            children: [
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: _glowSigma,
                  sigmaY: _glowSigma,
                  tileMode: TileMode.decal,
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    mood.glowColor,
                    BlendMode.srcIn,
                  ),
                  child: art,
                ),
              ),
              art,
            ],
          ),
        ),
      ),
    );
  }
}
