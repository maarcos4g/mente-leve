import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/parents/home/guide_detail_view.dart';
import 'package:mente_leve/modules/parents/home/parents_home_controller.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/utils/phone_dialer.dart';
import 'package:mente_leve/shared/widgets/guides/guide_card.dart';
import 'package:mente_leve/shared/widgets/profile/profile_sheet.dart';
import 'package:provider/provider.dart';

/// Home dos pais e responsáveis (`home / parents` — RF11): cabeçalho azul com
/// saudação e acesso ao perfil/logout, banner "Fale com a escola" e lista
/// dinâmica de "Guias e Orientações" publicados pela equipe escolar.
class ParentsHomeView extends StatefulWidget {
  const ParentsHomeView({
    super.key,
    this.user,
    this.controller,
    this.onContactSchool,
  });

  /// Usuário institucional carregado do Firestore (`users/{uid}`).
  /// Quando omitido, lê automaticamente da sessão ativa em [AuthNotifier].
  final UserModel? user;
  final ParentsHomeController? controller;
  final VoidCallback? onContactSchool;

  @override
  State<ParentsHomeView> createState() => _ParentsHomeViewState();
}

class _ParentsHomeViewState extends State<ParentsHomeView> {
  late final ParentsHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ParentsHomeController();
    _controller.addListener(_onChanged);
    _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  UserModel? _resolveUser(BuildContext context) {
    if (widget.user != null) return widget.user;
    try {
      final session = context.watch<AuthNotifier>().session;
      if (session is InstitutionalSession) {
        return session.user;
      }
    } catch (_) {
      // Provider pode não estar montado em testes isolados.
    }
    return null;
  }

  String _greetingTarget(UserModel? currentUser) {
    final raw = currentUser?.name.trim() ?? '';
    if (raw.isEmpty) return 'Família';
    return raw.split(RegExp(r'\s+')).first;
  }

  void _handleContactSchool() {
    if (widget.onContactSchool != null) {
      widget.onContactSchool!();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.zinc50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _SchoolContactSheet(
        onDialCvv: () async {
          Navigator.of(sheetContext).pop();
          final opened = await dialPhoneNumber('188');
          if (!opened && mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Não foi possível abrir o discador.'),
                ),
              );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _resolveUser(context);
    final greetingTarget = _greetingTarget(currentUser);
    final guides = _controller.guides;

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sky500,
            padding: const EdgeInsets.fromLTRB(16, 20, 12, 28),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Olá, ',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  height: 1.35,
                                  color: AppColors.zinc50,
                                ),
                              ),
                              TextSpan(
                                text: '$greetingTarget!',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: AppColors.zinc50,
                                ),
                              ),
                            ],
                          ),
                          key: const Key('parents_greeting_text'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Apoiando o desenvolvimento socioemocional',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.zinc100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('parents_profile_button'),
                    tooltip: 'Perfil e sair',
                    onPressed: () => showProfileSheet(context),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(
                      LucideIcons.logOut,
                      size: 24,
                      color: AppColors.zinc50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView(
                key: const Key('parents_home_list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _SchoolContactBanner(onTap: _handleContactSchool),
                  const SizedBox(height: 24),
                  Text(
                    'Guias e Orientações',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc950,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_controller.isLoading && !_controller.hasLoaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_controller.errorMessage != null)
                    _ParentsStateMessage(
                      key: const Key('parents_guides_error'),
                      icon: LucideIcons.triangleAlert,
                      message: _controller.errorMessage!,
                      actionKey: const Key('parents_guides_retry_button'),
                      actionLabel: 'Tentar novamente',
                      onAction: _controller.load,
                    )
                  else if (guides.isEmpty)
                    const _ParentsStateMessage(
                      key: Key('parents_guides_empty'),
                      icon: LucideIcons.bookOpen,
                      message: 'Nenhum guia publicado até o momento.',
                    )
                  else
                    for (var i = 0; i < guides.length; i++) ...[
                      GuideCard(
                        guide: guides[i],
                        colorIndex: i,
                        onTap:
                            () => GuideDetailView.open(
                              context,
                              guide: guides[i],
                              colorIndex: i,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner "Fale com a escola" fiel ao protótipo `home / parents`.
class _SchoolContactBanner extends StatelessWidget {
  const _SchoolContactBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Fale com a escola. Canal direto com a coordenação.',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.sky500,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('parents_contact_school_button'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.phoneCall,
                    size: 24,
                    color: AppColors.zinc50,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Fale com a escola',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.zinc50,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Canal direto com a coordenação',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.zinc50,
                          ),
                        ),
                      ],
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

class _SchoolContactSheet extends StatelessWidget {
  const _SchoolContactSheet({required this.onDialCvv});

  final VoidCallback onDialCvv;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D4D8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  LucideIcons.phoneCall,
                  size: 22,
                  color: AppColors.sky700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Fale com a escola',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc950,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Para agendar atendimento com a psicóloga escolar ou conversar '
              'com a coordenação pedagógica, procure a secretaria da escola no '
              'horário letivo ou utilize os canais oficiais informados pela '
              'instituição.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Precisa de apoio emocional imediato?',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.zinc950,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'O CVV atende 24 horas pelo número 188, de forma gratuita e '
                    'sigilosa.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.zinc950,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('parents_sheet_dial_cvv_button'),
                      onPressed: onDialCvv,
                      icon: const Icon(LucideIcons.phoneCall, size: 18),
                      label: Text(
                        'Ligar para o CVV (188)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sky700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: AppColors.sky700),
                child: Text(
                  'Fechar',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentsStateMessage extends StatelessWidget {
  const _ParentsStateMessage({
    super.key,
    required this.icon,
    required this.message,
    this.actionKey,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.slate600),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.slate600,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              key: actionKey,
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: AppColors.sky700,
              ),
              child: Text(
                actionLabel ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
