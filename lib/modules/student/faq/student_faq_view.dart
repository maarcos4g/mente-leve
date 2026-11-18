import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/faq/student_faq_controller.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';
import 'package:mente_leve/shared/widgets/faq/faq_expandable_card.dart';

/// Tela "Canais de Apoio & FAQ" do estudante fiel ao protótipo do Figma
/// (RF04, RF06 / SCRUM-33).
class StudentFaqView extends StatefulWidget {
  const StudentFaqView({
    super.key,
    this.controller,
    this.availableRoutes = const {},
    this.onCvvPressed,
  });

  final StudentFaqController? controller;
  final Set<String> availableRoutes;
  final VoidCallback? onCvvPressed;

  @override
  State<StudentFaqView> createState() => _StudentFaqViewState();
}

class _StudentFaqViewState extends State<StudentFaqView> {
  late final StudentFaqController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? StudentFaqController();
    _controller.addListener(_onChanged);
    _controller.carregar();
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleCvvTap() async {
    if (widget.onCvvPressed != null) {
      widget.onCvvPressed!();
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final opened = await CvvButton.dial();
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o discador.')),
      );
    }
  }

  void _handleReportTap() {
    if (widget.availableRoutes.contains(HomeController.reportRoute)) {
      Navigator.of(context).pushNamed(HomeController.reportRoute);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Disponível em breve.')));
  }

  @override
  Widget build(BuildContext context) {
    final items = _controller.items;

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FaqAppBar(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 108),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Canais de Apoio',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SupportChannelCard(
                      cardKey: const Key('support_channel_cvv'),
                      backgroundColor: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFE11D48),
                      icon: LucideIcons.phoneCall,
                      title: 'CVV - Centro de Valorização da vida',
                      subtitle: 'Ligue 188. Atendimento 24h, anônimo e seguro.',
                      onTap: _handleCvvTap,
                    ),
                    const SizedBox(height: 12),
                    _SupportChannelCard(
                      cardKey: const Key('support_channel_report'),
                      backgroundColor: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      icon: LucideIcons.messageSquare,
                      title: 'Denúncias anônimas à escola',
                      subtitle: 'Relate problemas de forma 100% anônima.',
                      onTap: _handleReportTap,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'FAQ e Dúvidas',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('faq_search_field'),
                      controller: _searchController,
                      onChanged: _controller.filtrar,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.zinc950,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar dúvida ou palavra-chave...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.slate600,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          size: 18,
                          color: AppColors.slate600,
                        ),
                        suffixIcon:
                            _controller.searchQuery.isNotEmpty
                                ? IconButton(
                                  key: const Key('faq_clear_search_button'),
                                  tooltip: 'Limpar busca',
                                  onPressed: () {
                                    _searchController.clear();
                                    _controller.filtrar('');
                                  },
                                  icon: const Icon(
                                    LucideIcons.x,
                                    size: 18,
                                    color: AppColors.slate600,
                                  ),
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4D4D8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD4D4D8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.sky700,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          _controller.errorMessage!,
                          key: const Key('faq_error_message'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.slate600,
                          ),
                        ),
                      )
                    else if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Nenhuma pergunta encontrada para sua busca.',
                          key: const Key('faq_empty_message'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.slate600,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        FaqExpandableCard(
                          item: items[i],
                          isExpanded: _controller.isExpanded(items[i].id),
                          onToggle: () => _controller.toggleExpanded(items[i].id),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqAppBar extends StatelessWidget {
  const _FaqAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('faq_back_button'),
            onPressed: onBack,
            tooltip: 'Voltar',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 24,
              color: AppColors.zinc950,
            ),
          ),
          Expanded(
            child: Text(
              'Canais de Apoio & FAQ',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.zinc950,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SupportChannelCard extends StatelessWidget {
  const _SupportChannelCard({
    required this.cardKey,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key cardKey;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: cardKey,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.zinc950,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
