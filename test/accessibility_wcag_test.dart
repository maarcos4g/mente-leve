import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_view.dart';
import 'package:mente_leve/modules/psychologist/reports/widgets/report_card.dart';
import 'package:mente_leve/modules/student/faq/student_faq_view.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/report_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/chat/chat_widgets.dart';
import 'package:mente_leve/shared/widgets/faq/faq_expandable_card.dart';

/// Calcula a razão de contraste WCAG 2.1 entre duas cores (1.0 a 21.0).
double wcagContrastRatio(Color a, Color b) {
  double channelLuminance(double c) {
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  double relativeLuminance(Color color) {
    final r = channelLuminance(color.r);
    final g = channelLuminance(color.g);
    final b = channelLuminance(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  final l1 = relativeLuminance(a);
  final l2 = relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Auditoria de Acessibilidade WCAG AA (SCRUM-41 / SCRUM-44)', () {
    setUp(() {
      LocalFaqRepository.instance.resetToDefaults();
    });

    test(
      'pares de cores de texto e botões cumprem contraste WCAG AA (>= 4.5:1)',
      () {
        // Texto principal (zinc950) sobre fundo claro (zinc50 / zinc100 / white)
        expect(
          wcagContrastRatio(AppColors.zinc950, AppColors.zinc50),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          wcagContrastRatio(AppColors.zinc950, AppColors.zinc100),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          wcagContrastRatio(AppColors.zinc950, Colors.white),
          greaterThanOrEqualTo(4.5),
        );

        // Texto secundário (slate600) sobre fundo claro (zinc50)
        expect(
          wcagContrastRatio(AppColors.slate600, AppColors.zinc50),
          greaterThanOrEqualTo(4.5),
        );

        // Botões primários (branco sobre sky700)
        expect(
          wcagContrastRatio(Colors.white, AppColors.sky700),
          greaterThanOrEqualTo(4.5),
        );

        // Card de FAQ expandido (#00598A sobre #DFF2FE — conforme Figma)
        expect(
          wcagContrastRatio(
            FaqExpandableCard.expandedTextColor,
            FaqExpandableCard.expandedBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );

        // Texto nos cards de canais de apoio do Figma (#FFE2E2 e #DFF2FE)
        expect(
          wcagContrastRatio(
            AppColors.zinc950,
            StudentFaqView.cvvCardBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          wcagContrastRatio(
            AppColors.zinc950,
            StudentFaqView.reportCardBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );

        // Card de canais oficiais (SCRUM-34): título e subtítulo
        expect(
          wcagContrastRatio(
            AppColors.zinc950,
            StudentFaqView.officialChannelsCardBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          wcagContrastRatio(
            AppColors.slate600,
            StudentFaqView.officialChannelsCardBackground,
          ),
          greaterThanOrEqualTo(4.5),
        );

        // Ícone do card de canais oficiais sobre branco: elemento gráfico,
        // WCAG 1.4.11 pede >= 3:1
        expect(
          wcagContrastRatio(
            StudentFaqView.officialChannelsIconColor,
            Colors.white,
          ),
          greaterThanOrEqualTo(3.0),
        );
      },
    );

    testWidgets(
      'controles interativos na StudentFaqView possuem área mínima de toque >= 48x48dp',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: StudentFaqView()));
        await tester.pumpAndSettle();

        final backSize = tester.getSize(
          find.byKey(const Key('faq_back_button')),
        );
        expect(backSize.width, greaterThanOrEqualTo(48));
        expect(backSize.height, greaterThanOrEqualTo(48));

        final cvvCardSize = tester.getSize(
          find.byKey(const Key('support_channel_cvv')),
        );
        expect(cvvCardSize.width, greaterThanOrEqualTo(48));
        expect(cvvCardSize.height, greaterThanOrEqualTo(48));

        final officialCardSize = tester.getSize(
          find.byKey(const Key('support_channel_official')),
        );
        expect(officialCardSize.width, greaterThanOrEqualTo(48));
        expect(officialCardSize.height, greaterThanOrEqualTo(48));

        final reportCardSize = tester.getSize(
          find.byKey(const Key('support_channel_report')),
        );
        expect(reportCardSize.width, greaterThanOrEqualTo(48));
        expect(reportCardSize.height, greaterThanOrEqualTo(48));

        final faqCardSize = tester.getSize(
          find.byKey(const Key('faq_card_faq-cyberbullying')),
        );
        expect(faqCardSize.width, greaterThanOrEqualTo(48));
        expect(faqCardSize.height, greaterThanOrEqualTo(48));
      },
    );

    testWidgets(
      'controles interativos na PsychologistFaqView (incluindo ações de swipe) possuem área mínima >= 48x48dp',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: PsychologistFaqView()),
        );
        await tester.pumpAndSettle();

        final backSize = tester.getSize(
          find.byKey(const Key('psychologist_faq_back_button')),
        );
        expect(backSize.width, greaterThanOrEqualTo(48));
        expect(backSize.height, greaterThanOrEqualTo(48));

        final submitSize = tester.getSize(
          find.byKey(const Key('faq_submit_button')),
        );
        expect(submitSize.width, greaterThanOrEqualTo(48));
        expect(submitSize.height, greaterThanOrEqualTo(48));

        // Arrasta card para a esquerda para revelar ações e auditar áreas de toque
        final swipeTarget = find.byKey(const Key('faq_swipe_faq-cyberbullying'));
        await tester.ensureVisible(swipeTarget);
        await tester.drag(swipeTarget, const Offset(-100, 0));
        await tester.pumpAndSettle();

        final editSize = tester.getSize(
          find.byKey(const Key('faq_edit_faq-cyberbullying')),
        );
        expect(editSize.width, greaterThanOrEqualTo(48));
        expect(editSize.height, greaterThanOrEqualTo(48));

        final deleteSize = tester.getSize(
          find.byKey(const Key('faq_delete_faq-cyberbullying')),
        );
        expect(deleteSize.width, greaterThanOrEqualTo(48));
        expect(deleteSize.height, greaterThanOrEqualTo(48));
      },
    );

    test('selos de gravidade e status da triagem cumprem contraste AA (RF09)', () {
      for (final severity in ReportSeverity.values) {
        final colors = BadgeColors.forSeverity(severity);
        expect(
          wcagContrastRatio(colors.foreground, colors.background),
          greaterThanOrEqualTo(4.5),
          reason: 'gravidade ${severity.name}',
        );
      }
      for (final status in ReportStatus.values) {
        final colors = BadgeColors.forStatus(status);
        expect(
          wcagContrastRatio(colors.foreground, colors.background),
          greaterThanOrEqualTo(4.5),
          reason: 'status ${status.name}',
        );
      }
      // Texto branco do chip de filtro selecionado e dos botões da triagem.
      expect(
        wcagContrastRatio(Colors.white, AppColors.sky700),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('balões do chat anônimo cumprem contraste AA (RF05)', () {
      expect(
        wcagContrastRatio(ChatColors.ownText, ChatColors.ownBubble),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        wcagContrastRatio(ChatColors.otherText, ChatColors.otherBubble),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        wcagContrastRatio(ChatColors.otherMeta, ChatColors.otherBubble),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
