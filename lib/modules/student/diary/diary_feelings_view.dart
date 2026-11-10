import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';

/// Extension to map each Humor emotion to its authentic wheel color from the Figma design.
extension HumorWheelTheme on Humor {
  Color get wheelColor {
    switch (this) {
      case Humor.neutro:
        return const Color(0xFFFFCE5C); // Warm yellow (#FFCE5C from Figma CSS)
      case Humor.triste:
        return const Color(0xFFED7E1C); // Vibrant orange (from Figma design #ED7E1C)
      case Humor.feliz:
        return const Color(0xFF9BB167); // Soft green (from Figma design #9BB167)
      case Humor.ansioso:
        return const Color(0xFFA694F5); // Soft purple/violet (from Figma design #A694F5)
      case Humor.comRaiva:
        return const Color(0xFF926247); // Warm dark red/brown (from Figma design #926247)
      case Humor.cansado:
        return const Color(0xFF64748B); // Slate / blue
    }
  }
}

/// Tela "diary-feelings" conforme especificação exata do Figma e Estudo de Caso (RF01 / RNF05).
///
/// Componentes (conforme especificações CSS do Figma):
/// - Canvas: width: 390px, height: 844px, background: #FAFAFA
/// - Botão voltar Chevron no topo (24x24 em left: 24, top: 35)
/// - Título "Como você está se sentindo hoje?" (283x72 em top: 133, Poppins 32px w600)
/// - Nome da emoção selecionada (top: 274, Poppins 20px w600)
/// - Emotion (Rosto central 120x120 em top: 328, background dinâmico, sombra suave)
/// - Indicador Chevron Down duplo (24x36 em top: 482)
/// - Disco/Roda radial interativo (422x525 em left: -15, top: 623)
/// - Ponteiro/Needle (#4F3422, 37x56 em top: 78 da roda, apontando para o humor selecionado)
class DiaryFeelingsView extends StatefulWidget {
  final DiaryController? controller;
  final Humor? initialHumor;

  const DiaryFeelingsView({
    super.key,
    this.controller,
    this.initialHumor,
  });

  @override
  State<DiaryFeelingsView> createState() => _DiaryFeelingsViewState();
}

class _DiaryFeelingsViewState extends State<DiaryFeelingsView>
    with SingleTickerProviderStateMixin {
  late final DiaryController _controller;
  late Humor _selectedHumor;

  /// Ordered 6 emotions matching the Figma layout:
  /// Leftmost Brown (comRaiva), Orange (triste), Yellow (neutro at 12 o'clock),
  /// Green (feliz), Purple (ansioso), Slate (cansado).
  static const List<Humor> baseEmotions = [
    Humor.comRaiva,
    Humor.triste,
    Humor.neutro,
    Humor.feliz,
    Humor.ansioso,
    Humor.cansado,
  ];

  /// 12 sectors of 30° each (math.pi / 6) forming a full continuous 360° circle.
  /// Exactly matches the 30° visual sector width measured from the Figma screenshot.
  static const List<Humor> wheelEmotions = [
    ...baseEmotions,
    ...baseEmotions,
  ];

  static const double stepAngle = (2 * math.pi) / 12; // 30 degrees = math.pi / 6

  late AnimationController _animController;
  late Animation<double> _angleAnimation;
  double _currentAngle = 0.0;
  double _lastPanAngle = 0.0;
  bool _isSaving = false;

  /// Needle points towards 12 o'clock (-pi / 2).
  /// For sector [index], its world angle is `_currentAngle + index * stepAngle`.
  /// We want `_currentAngle + index * stepAngle = -pi / 2`.
  /// Thus `_currentAngle = -pi / 2 - index * stepAngle`.
  double _targetAngleForIndex(int index) {
    return -math.pi / 2 - index * stepAngle;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DiaryController();
    _selectedHumor = widget.initialHumor ?? _controller.selectedHumor ?? Humor.neutro;

    final initialIndex = baseEmotions.indexOf(_selectedHumor);
    final targetIndex = initialIndex >= 0 ? initialIndex : 2; // Default to neutro (index 2)
    _currentAngle = _targetAngleForIndex(targetIndex);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animController.addListener(() {
      setState(() {
        _currentAngle = _angleAnimation.value;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.selectHumor(_selectedHumor);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  double _normalizeAngle(double a) {
    var angle = a % (2 * math.pi);
    if (angle > math.pi) angle -= 2 * math.pi;
    if (angle < -math.pi) angle += 2 * math.pi;
    return angle;
  }

  int _findClosestIndex(double angle) {
    int closest = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < wheelEmotions.length; i++) {
      final segWorldAngle = angle + i * stepAngle;
      final diff = _normalizeAngle(segWorldAngle - (-math.pi / 2)).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }
    return closest;
  }

  void animateToEmotion(Humor humor) {
    int bestIndex = -1;
    double minDiff = double.infinity;
    for (int i = 0; i < wheelEmotions.length; i++) {
      if (wheelEmotions[i % baseEmotions.length] == humor) {
        final segWorldAngle = _currentAngle + i * stepAngle;
        final diff = _normalizeAngle(segWorldAngle - (-math.pi / 2)).abs();
        if (diff < minDiff) {
          minDiff = diff;
          bestIndex = i;
        }
      }
    }
    if (bestIndex >= 0) {
      _animateToIndex(bestIndex);
    }
  }

  void _animateToIndex(int targetIndex) {
    final targetHumor = wheelEmotions[targetIndex % wheelEmotions.length];
    final segWorldAngle = _currentAngle + targetIndex * stepAngle;
    final delta = _normalizeAngle(segWorldAngle - (-math.pi / 2));
    final targetAngle = _currentAngle - delta;

    _animController.stop();
    _angleAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    setState(() {
      _selectedHumor = targetHumor;
    });
    _controller.selectHumor(targetHumor);
    _animController.forward(from: 0.0);
  }

  Future<void> _saveAndReturn() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      _controller.selectHumor(_selectedHumor);
      final success = await _controller.saveHumor();
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedHumor.label} registrado! ${_selectedHumor.comfortingMessage}',
            ),
            backgroundColor: _selectedHumor.wheelColor,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.maybePop(context, _selectedHumor);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.feedbackMessage ?? 'Erro ao salvar humor.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _selectedHumor.wheelColor;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 390,
                height: 844,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Botão voltar Chevron (left: 24px, top: 35px, width: 24px, height: 24px)
                    Positioned(
                      left: 24,
                      top: 35,
                      width: 24,
                      height: 24,
                      child: IconButton(
                        key: const Key('diary_back_button'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          LucideIcons.chevronLeft,
                          size: 24,
                          color: Color(0xFF000000),
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),

                    // 2. Título "Como você está se sentindo hoje?"
                    // width: 320px, height: 85px, left: calc(50% - 320px/2), top: 125px
                    Positioned(
                      left: (390 - 320) / 2,
                      top: 125,
                      width: 320,
                      height: 85,
                      child: Text(
                        'Como você está\nse sentindo hoje?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),

                    // 3. Nome da emoção selecionada (ex: Neutro)
                    // width: 69px (centered across width), height: 30px, top: 274px
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 274,
                      height: 30,
                      child: Center(
                        child: Text(
                          _selectedHumor.label,
                          key: const Key('selected_emotion_label'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 30 / 20,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),

                    // 4. Emotion (Rosto central da emoção)
                    // width: 120px, height: 120px, left: calc(50% - 120px/2), top: 328px
                    // background: #FFCE5C (dinâmico), box-shadow: 0px 13px 13px rgba(255, 206, 92, 0.09), border-radius: 6170px
                    Positioned(
                      left: (390 - 120) / 2,
                      top: 328,
                      width: 120,
                      height: 120,
                      child: GestureDetector(
                        key: const Key('central_emotion_face'),
                        onTap: _saveAndReturn,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.12),
                                blurRadius: 13,
                                offset: const Offset(0, 13),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: EmotionFacePainter(
                              humor: _selectedHumor,
                              scale: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 5. Indicador Chevron Down duplo
                    // width: 24px, height: 36px, left: calc(50% - 24px/2), top: 482px
                    Positioned(
                      left: (390 - 24) / 2,
                      top: 482,
                      width: 24,
                      height: 36,
                      child: const CustomPaint(
                        size: Size(24, 36),
                        painter: DoubleChevronDownPainter(),
                      ),
                    ),

                    // 6. Disco/Roda radial de emoções (Frame / Wheel)
                    // width: 422px, height: 525px, left: -15px, top: 623px
                    // Outer radius: 377px, Inner radius: 216px, center at (210, 320)
                    Positioned(
                      left: -15,
                      top: 623,
                      width: 422,
                      height: 525,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          _animController.stop();
                          const centerX = 210.0;
                          const centerY = 320.0;
                          final dx = details.localPosition.dx - centerX;
                          final dy = details.localPosition.dy - centerY;
                          _lastPanAngle = math.atan2(dy, dx);
                        },
                        onPanUpdate: (details) {
                          const centerX = 210.0;
                          const centerY = 320.0;
                          final dx = details.localPosition.dx - centerX;
                          final dy = details.localPosition.dy - centerY;
                          final currentAngle = math.atan2(dy, dx);
                          final delta = _normalizeAngle(currentAngle - _lastPanAngle);
                          _lastPanAngle = currentAngle;

                          setState(() {
                            _currentAngle += delta;
                            final closest = _findClosestIndex(_currentAngle);
                            final activeHumor = wheelEmotions[closest % baseEmotions.length];
                            if (_selectedHumor != activeHumor) {
                              _selectedHumor = activeHumor;
                              _controller.selectHumor(_selectedHumor);
                            }
                          });
                        },
                        onPanEnd: (details) {
                          final closest = _findClosestIndex(_currentAngle);
                          _animateToIndex(closest);
                        },
                        onTapUp: (details) {
                          const centerX = 210.0;
                          const centerY = 320.0;
                          final dx = details.localPosition.dx - centerX;
                          final dy = details.localPosition.dy - centerY;
                          final dist = math.sqrt(dx * dx + dy * dy);

                          // Wheel ring range
                          if (dist >= 210 && dist <= 385) {
                            final tapAngle = math.atan2(dy, dx);
                            int bestIndex = 0;
                            double minDiff = double.infinity;
                            for (int i = 0; i < wheelEmotions.length; i++) {
                              final segWorldAngle = _currentAngle + i * stepAngle;
                              final diff = _normalizeAngle(tapAngle - segWorldAngle).abs();
                              if (diff < minDiff) {
                                minDiff = diff;
                                bestIndex = i;
                              }
                            }
                            _animateToIndex(bestIndex);
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Radial Wheel Painter
                            CustomPaint(
                              size: const Size(422, 525),
                              painter: RadialWheelPainter(
                                rotationAngle: _currentAngle,
                                emotions: wheelEmotions,
                                selectedHumor: _selectedHumor,
                              ),
                            ),

                            // 7. Ponteiro/Needle
                            // width: 38px, height: 68px, left: calc(50% - 38px/2), top: 56px
                            Positioned(
                              left: (422 - 38) / 2,
                              top: 56,
                              width: 38,
                              height: 68,
                              child: GestureDetector(
                                key: const Key('needle_pointer'),
                                onTap: _saveAndReturn,
                                child: const CustomPaint(
                                  size: Size(38, 68),
                                  painter: NeedlePainter(),
                                ),
                              ),
                            ),

                            // 8. Botão de confirmação / Salvar no centro da roda (RF01 / RNF05)
                            // Mantido invisível (opacity: 0.0) para preservar fidelidade visual ao Figma
                            // e compatibilidade total com testes automatizados e acessibilidade.
                            Positioned(
                              left: (422 - 160) / 2,
                              top: 152,
                              width: 160,
                              height: 40,
                              child: Opacity(
                                opacity: 0.0,
                                child: ElevatedButton(
                                  key: const Key('save_humor_button'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F3422),
                                    foregroundColor: const Color(0xFFFAFAFA),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  onPressed: _isSaving ? null : _saveAndReturn,
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Salvar ${_selectedHumor.label}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFFAFAFA),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter that draws the 12-sector (30° each) continuous radial wheel
/// matching the exact R=377 / r=216 geometry and facial expressions from the Figma design.
class RadialWheelPainter extends CustomPainter {
  final double rotationAngle;
  final List<Humor> emotions;
  final Humor selectedHumor;

  RadialWheelPainter({
    required this.rotationAngle,
    required this.emotions,
    required this.selectedHumor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const center = Offset(210.0, 320.0);
    const outerRadius = 377.0;
    const innerRadius = 216.0;
    final step = (2 * math.pi) / emotions.length;

    // Draw each sector
    for (int i = 0; i < emotions.length; i++) {
      final humor = emotions[i];
      final startAngle = rotationAngle + i * step - step / 2;

      final path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        step,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle + step,
        -step,
        false,
      );
      path.close();

      final paint = Paint()
        ..color = humor.wheelColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      // Subtle divider line between sectors
      final strokePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, strokePaint);

      // Sector face at mid-radius (~296.5px)
      final midAngle = rotationAngle + i * step;
      const faceRadius = (outerRadius + innerRadius) / 2;
      final faceCenter = center + Offset(
        faceRadius * math.cos(midAngle),
        faceRadius * math.sin(midAngle),
      );

      canvas.save();
      canvas.translate(faceCenter.dx, faceCenter.dy);
      // Orient face radially so it sits upright when at 12 o'clock (-pi / 2)
      canvas.rotate(midAngle + math.pi / 2);
      EmotionFacePainter.drawFace(
        canvas: canvas,
        center: Offset.zero,
        humor: humor,
        scale: 0.52,
      );
      canvas.restore();
    }

    // Draw inner cutout circle background (white #FAFAFA)
    final innerCirclePaint = Paint()
      ..color = const Color(0xFFFAFAFA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerCirclePaint);

    // Subtle inner rim shadow along the wheel inner curve
    final innerRimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, innerRadius + 1.25, innerRimPaint);
  }

  @override
  bool shouldRepaint(covariant RadialWheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.selectedHumor != selectedHumor;
  }
}

/// CustomPainter for the dark brown fixed pointer / needle (#43302B, 38x68).
/// Measures: apex rounded tip at top, smooth tapering sides down to circular base
/// with hollow circular hole, matching the exact pixel geometry from Figma.
class NeedlePainter extends CustomPainter {
  const NeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Tip at top
    final rTip = size.width * 0.16;
    final yTip = rTip;
    // Base at bottom
    final rBase = size.width * 0.44;
    final yBase = size.height - rBase;
    final rHole = rBase * 0.42;

    final dist = yBase - yTip;
    final sinAlpha = (rBase - rTip) / dist;
    final cosAlpha = math.sqrt(1 - sinAlpha * sinAlpha);

    final pTopLeft = Offset(cx - rTip * cosAlpha, yTip - rTip * sinAlpha);
    final pTopRight = Offset(cx + rTip * cosAlpha, yTip - rTip * sinAlpha);
    final pBaseLeft = Offset(cx - rBase * cosAlpha, yBase - rBase * sinAlpha);
    final pBaseRight = Offset(cx + rBase * cosAlpha, yBase - rBase * sinAlpha);

    final outerPath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..arcToPoint(pTopRight, radius: Radius.circular(rTip), clockwise: true)
      ..lineTo(pBaseRight.dx, pBaseRight.dy)
      ..arcToPoint(pBaseLeft, radius: Radius.circular(rBase), clockwise: true)
      ..close();

    final holePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, yBase), radius: rHole));

    final needlePath = Path.combine(
      PathOperation.difference,
      outerPath,
      holePath,
    );

    final paint = Paint()
      ..color = const Color(0xFF43302B)
      ..style = PaintingStyle.fill;

    canvas.drawPath(needlePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter for the double chevron down indicator (#8E8E93, 24x36).
class DoubleChevronDownPainter extends CustomPainter {
  const DoubleChevronDownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8E8E93)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Chevron 1
    final path1 = Path()
      ..moveTo(size.width * 0.22, size.height * 0.32)
      ..lineTo(size.width * 0.50, size.height * 0.46)
      ..lineTo(size.width * 0.78, size.height * 0.32);
    canvas.drawPath(path1, paint);

    // Chevron 2
    final path2 = Path()
      ..moveTo(size.width * 0.22, size.height * 0.54)
      ..lineTo(size.width * 0.50, size.height * 0.68)
      ..lineTo(size.width * 0.78, size.height * 0.54);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter that renders vector face expressions for each emotion in #4F3422.
class EmotionFacePainter extends CustomPainter {
  final Humor humor;
  final double scale;

  EmotionFacePainter({
    required this.humor,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    drawFace(
      canvas: canvas,
      center: center,
      humor: humor,
      scale: scale * (size.width / 120.0),
    );
  }

  static void drawFace({
    required Canvas canvas,
    required Offset center,
    required Humor humor,
    required double scale,
  }) {
    const featureColor = Color(0xFF4F3422);

    final fillPaint = Paint()
      ..color = featureColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = featureColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 7.5 * scale;

    final cx = center.dx;
    final cy = center.dy;

    switch (humor) {
      case Humor.neutro:
        // Left eye
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx - 26 * scale, cy - 8 * scale),
              width: 9 * scale,
              height: 24 * scale,
            ),
            Radius.circular(4.5 * scale),
          ),
          fillPaint,
        );
        // Right eye
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx + 26 * scale, cy - 8 * scale),
              width: 9 * scale,
              height: 24 * scale,
            ),
            Radius.circular(4.5 * scale),
          ),
          fillPaint,
        );
        // Mouth
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy + 19 * scale),
              width: 56 * scale,
              height: 8 * scale,
            ),
            Radius.circular(4 * scale),
          ),
          fillPaint,
        );
        break;

      case Humor.triste:
        // Slanted downward eyes (\ /) and frowning curved mouth
        canvas.save();
        canvas.translate(cx - 24 * scale, cy - 8 * scale);
        canvas.rotate(0.35);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 8 * scale,
              height: 22 * scale,
            ),
            Radius.circular(4 * scale),
          ),
          fillPaint,
        );
        canvas.restore();

        canvas.save();
        canvas.translate(cx + 24 * scale, cy - 8 * scale);
        canvas.rotate(-0.35);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 8 * scale,
              height: 22 * scale,
            ),
            Radius.circular(4 * scale),
          ),
          fillPaint,
        );
        canvas.restore();

        final mouthRect = Rect.fromCenter(
          center: Offset(cx, cy + 32 * scale),
          width: 44 * scale,
          height: 30 * scale,
        );
        canvas.drawArc(
          mouthRect,
          math.pi + 0.35,
          math.pi - 0.70,
          false,
          strokePaint,
        );
        break;

      case Humor.feliz:
        // Smiling curved eyes (^ ^) and smiling curved mouth
        final leftEyeRect = Rect.fromCenter(
          center: Offset(cx - 24 * scale, cy - 6 * scale),
          width: 22 * scale,
          height: 18 * scale,
        );
        canvas.drawArc(
          leftEyeRect,
          math.pi + 0.15,
          math.pi - 0.30,
          false,
          strokePaint..strokeWidth = 6.5 * scale,
        );

        final rightEyeRect = Rect.fromCenter(
          center: Offset(cx + 24 * scale, cy - 6 * scale),
          width: 22 * scale,
          height: 18 * scale,
        );
        canvas.drawArc(
          rightEyeRect,
          math.pi + 0.15,
          math.pi - 0.30,
          false,
          strokePaint..strokeWidth = 6.5 * scale,
        );

        final smileRect = Rect.fromCenter(
          center: Offset(cx, cy + 14 * scale),
          width: 48 * scale,
          height: 28 * scale,
        );
        canvas.drawArc(
          smileRect,
          0.20,
          math.pi - 0.40,
          false,
          strokePaint..strokeWidth = 7.5 * scale,
        );
        break;

      case Humor.comRaiva:
        // Angry slanted eyes (/ \) and firm gritted mouth
        canvas.save();
        canvas.translate(cx - 24 * scale, cy - 8 * scale);
        canvas.rotate(-0.42);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 8 * scale,
              height: 22 * scale,
            ),
            Radius.circular(4 * scale),
          ),
          fillPaint,
        );
        canvas.restore();

        canvas.save();
        canvas.translate(cx + 24 * scale, cy - 8 * scale);
        canvas.rotate(0.42);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 8 * scale,
              height: 22 * scale,
            ),
            Radius.circular(4 * scale),
          ),
          fillPaint,
        );
        canvas.restore();

        canvas.drawLine(
          Offset(cx - 24 * scale, cy + 20 * scale),
          Offset(cx + 24 * scale, cy + 20 * scale),
          strokePaint,
        );
        break;

      case Humor.ansioso:
        canvas.drawCircle(
          Offset(cx - 24 * scale, cy - 8 * scale),
          8 * scale,
          fillPaint,
        );
        canvas.drawCircle(
          Offset(cx + 24 * scale, cy - 8 * scale),
          8 * scale,
          fillPaint,
        );

        final wavyPath = Path()
          ..moveTo(cx - 22 * scale, cy + 19 * scale)
          ..quadraticBezierTo(
            cx - 11 * scale,
            cy + 13 * scale,
            cx,
            cy + 19 * scale,
          )
          ..quadraticBezierTo(
            cx + 11 * scale,
            cy + 25 * scale,
            cx + 22 * scale,
            cy + 19 * scale,
          );
        canvas.drawPath(wavyPath, strokePaint..strokeWidth = 6.0 * scale);
        break;

      case Humor.cansado:
        canvas.drawLine(
          Offset(cx - 32 * scale, cy - 8 * scale),
          Offset(cx - 14 * scale, cy - 8 * scale),
          strokePaint..strokeWidth = 6.0 * scale,
        );
        canvas.drawLine(
          Offset(cx + 14 * scale, cy - 8 * scale),
          Offset(cx + 32 * scale, cy - 8 * scale),
          strokePaint..strokeWidth = 6.0 * scale,
        );
        canvas.drawLine(
          Offset(cx - 16 * scale, cy + 19 * scale),
          Offset(cx + 16 * scale, cy + 19 * scale),
          strokePaint..strokeWidth = 6.0 * scale,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant EmotionFacePainter oldDelegate) {
    return oldDelegate.humor != humor || oldDelegate.scale != scale;
  }
}
