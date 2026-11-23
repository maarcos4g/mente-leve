import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_view.dart';
import 'package:mente_leve/modules/psychologist/reports/widgets/reports_summary_card.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/profile/profile_sheet.dart';
import 'package:provider/provider.dart';

class PsychologistHomeView extends StatelessWidget {
  const PsychologistHomeView({super.key, this.user});

  /// Usuário institucional carregado do Firestore (`users/{uid}`).
  /// Quando omitido, lê automaticamente da sessão ativa em [AuthNotifier].
  final UserModel? user;

  UserModel? _resolveUser(BuildContext context) {
    if (user != null) return user;
    try {
      final session = context.watch<AuthNotifier>().session;
      if (session is InstitutionalSession) {
        return session.user;
      }
    } catch (_) {
      // Provider pode não estar presente em testes isolados.
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _resolveUser(context);
    final displayName = currentUser?.name.trim() ?? '';
    final greeting = displayName.isNotEmpty ? 'Olá, $displayName!' : 'Olá!';
    final photoUrl = currentUser?.photoUrl?.trim();

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sky500,
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'menteleve',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc50,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PsychologistAvatar(
                            photoUrl: photoUrl,
                            displayName: displayName,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            key: const Key('psychologist_profile_button'),
                            tooltip: 'Perfil',
                            onPressed: () => showProfileSheet(context),
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            icon: const Icon(
                              LucideIcons.user,
                              size: 20,
                              color: AppColors.zinc50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                    greeting,
                    key: const Key('psychologist_greeting_text'),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc50,
                    ),
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
                  const ReportsSummaryCard(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.topLeft,
                    child: _PsychologistActionCard(
                      cardKey: const Key('psychologist_open_faq_button'),
                      icon: LucideIcons.circleQuestionMark,
                      iconBackgroundColor: const Color(0xFFB8E6FE),
                      iconColor: AppColors.sky700,
                      title: 'Editar Perguntas\nFrequentes (FAQ)',
                      onTap:
                          () => Navigator.of(
                            context,
                          ).pushNamed(PsychologistFaqView.routeName),
                    ),
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

class _PsychologistAvatar extends StatelessWidget {
  const _PsychologistAvatar({
    required this.photoUrl,
    required this.displayName,
  });

  final String? photoUrl;
  final String displayName;

  Widget _buildFallback() {
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child:
          initial != null
              ? Text(
                initial,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sky700,
                ),
              )
              : const Icon(
                LucideIcons.user,
                size: 20,
                color: AppColors.sky700,
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Semantics(
      image: true,
      label:
          displayName.isNotEmpty
              ? 'Foto de perfil de $displayName'
              : 'Foto de perfil da psicóloga',
      child: SizedBox(
        key: const Key('psychologist_avatar'),
        width: 40,
        height: 40,
        child:
            hasPhoto
                ? ClipOval(
                  child: Image.network(
                    photoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildFallback(),
                  ),
                )
                : _buildFallback(),
      ),
    );
  }
}

/// Card compacto fiel às medidas do Figma (152x142, fundo #F4F4F5,
/// borda #D4D4D8 e badge circular de ícone 40x40 em #B8E6FE).
class _PsychologistActionCard extends StatelessWidget {
  const _PsychologistActionCard({
    required this.cardKey,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final Key cardKey;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title.replaceAll('\n', ' '),
      child: SizedBox(
        width: 152,
        height: 142,
        child: Material(
          color: AppColors.zinc100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4D4D8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: cardKey,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: iconColor),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: AppColors.zinc950,
                      ),
                    ),
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
