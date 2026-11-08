import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/widgets/mood_selector_card.dart';
import 'package:mente_leve/modules/student/diary/widgets/recent_moods_summary.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Tela principal do aluno (Home / Diário de Sentimentos).
///
/// Apresenta como ação primária central o Diário de Sentimentos por Emojis (RF01),
/// concluível em até 3 interações (RNF05).
/// Inclui o pill button de emergência CVV 188 (RF03 / RN04) e navegação por abas.
class StudentHomeView extends StatefulWidget {
  final String? initialNickname;
  final String? initialAvatarPath;
  final DiaryController? controller;

  const StudentHomeView({
    super.key,
    this.initialNickname,
    this.initialAvatarPath,
    this.controller,
  });

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  late final DiaryController _diaryController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _diaryController = widget.controller ?? DiaryController();
    _diaryController.init();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _diaryController.dispose();
    }
    super.dispose();
  }

  void _showCvvDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: TailwindColors.sky100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.phone,
                    color: TailwindColors.sky600,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'CVV 188 — Centro de Valorização da Vida',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TailwindColors.zinc900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apoio emocional gratuito, sigiloso e disponível 24 horas por dia. Funciona mesmo sem internet ou dados.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionBody.copyWith(
                    color: TailwindColors.zinc600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TailwindColors.sky600,
                      foregroundColor: TailwindColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Discaremos para 188 (CVV gratuito)'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Ligar 188 agora',
                      style: AppTextStyles.buttonHeading.copyWith(
                        color: TailwindColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Voltar',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: TailwindColors.zinc500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    String nickname = widget.initialNickname ?? 'Panda';
    String avatarPath = widget.initialAvatarPath ?? 'panda.svg';

    if (routeArgs is Map) {
      if (routeArgs['nickname'] is String &&
          (routeArgs['nickname'] as String).trim().isNotEmpty) {
        nickname = routeArgs['nickname'] as String;
      }
      if (routeArgs['avatarPath'] is String &&
          (routeArgs['avatarPath'] as String).trim().isNotEmpty) {
        avatarPath = routeArgs['avatarPath'] as String;
      }
    }

    return Scaffold(
      backgroundColor: TailwindColors.zinc50,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho acolhedor com avatar e codinome do aluno
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: TailwindColors.sky500,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140284C7),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/avatars/$avatarPath',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $nickname!',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: TailwindColors.zinc900,
                          ),
                        ),
                        Text(
                          'Seu porto seguro, direto no bolso',
                          style: AppTextStyles.textXs.copyWith(
                            color: TailwindColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Funcionalidade central: Diário de Sentimentos por Emojis (RF01)
              MoodSelectorCard(
                controller: _diaryController,
                onCvvTap: _showCvvDialog,
              ),

              const SizedBox(height: 20),

              // Resumo da semana (RF01 / RF06)
              RecentMoodsSummary(
                controller: _diaryController,
              ),

              const SizedBox(height: 20),

              // Card do mascote de acolhimento
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TailwindColors.sky50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TailwindColors.sky200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: TailwindColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🐼', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dica do Mascote',
                            style: AppTextStyles.captionMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TailwindColors.sky900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Registrar o que você sente ajuda a clarear os pensamentos. Pegue leve com você hoje!',
                            style: AppTextStyles.textXs.copyWith(
                              color: TailwindColors.sky800,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Espaço final para não sobrepor o pill button
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),

      // Pill button flutuante para CVV 188 (RF03 / RN04)
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cvv_emergency_button',
        onPressed: _showCvvDialog,
        backgroundColor: TailwindColors.sky500,
        foregroundColor: TailwindColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        icon: const Icon(LucideIcons.phone, size: 18),
        label: Text(
          'Ajuda (CVV)',
          style: AppTextStyles.captionMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: TailwindColors.white,
          ),
        ),
      ),

      // Barra inferior com 4 abas (justificativas.md - Seção 3)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() => _currentTabIndex = index);
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  index == 1
                      ? 'Diário Reflexivo em desenvolvimento (RF02)'
                      : index == 2
                          ? 'FAQ e Dúvidas em desenvolvimento (RF04)'
                          : 'Canais de Denúncia em desenvolvimento (RF05)',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: TailwindColors.white,
        selectedItemColor: TailwindColors.sky600,
        unselectedItemColor: TailwindColors.zinc400,
        selectedLabelStyle: AppTextStyles.captionXs.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.captionXs,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.smile),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.penLine),
            label: 'Escrever',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.circleHelp),
            label: 'Ajuda/FAQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.shield),
            label: 'Canais',
          ),
        ],
      ),
    );
  }
}
