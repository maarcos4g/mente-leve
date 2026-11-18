import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_view.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:provider/provider.dart';

class PsychologistHomeView extends StatelessWidget {
  const PsychologistHomeView({super.key});

  String _resolveUserName(BuildContext context) {
    try {
      final session = context.watch<AuthNotifier>().session;
      if (session is InstitutionalSession &&
          session.user.name.trim().isNotEmpty) {
        return session.user.name.trim();
      }
    } catch (_) {
      // Provider pode não estar presente em testes isolados.
    }
    return 'Camila';
  }

  @override
  Widget build(BuildContext context) {
    final name = _resolveUserName(context);

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sky500,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Painel Institucional',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.zinc50.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Olá, $name!',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.zinc50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await context.read<AuthNotifier>().signOut();
                      nav.pushNamedAndRemoveUntil('/onboarding', (_) => false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.zinc50,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PsychologistActionCard(
                    cardKey: const Key('psychologist_open_faq_button'),
                    icon: LucideIcons.circleQuestionMark,
                    iconColor: AppColors.sky700,
                    title: 'Editar Perguntas Frequentes (FAQ)',
                    subtitle:
                        'Cadastre, atualize ou remova perguntas e orientações acessadas pelos alunos.',
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pushNamed(PsychologistFaqView.routeName),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PsychologistActionCard extends StatelessWidget {
  const _PsychologistActionCard({
    required this.cardKey,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key cardKey;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.sky700, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: cardKey,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.zinc950,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: AppColors.sky700,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
