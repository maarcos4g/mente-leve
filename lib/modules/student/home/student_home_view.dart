import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/diary_feelings_view.dart';
import 'package:mente_leve/modules/student/diary/diary_reflection_view.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Tela principal do aluno (Home) desenvolvida exatamente conforme as
/// especificações CSS do Figma:
///
/// - Canvas: width: 390px, height: 844px, background: #FAFAFA
/// - Header (Rectangle 3): 390x140, background: #00A6F4
/// - Header content (Frame 100): 352x72 em top: 44px
///   - "Olá, Panda!" / nome do aluno (Poppins 24px w300 line-height 36px #FAFAFA)
///   - Avatar container (64x64, #FAFAFA, border-radius: 16px, panda 48x48)
/// - Botão "Como está sua mente hoje?" (Frame 101): 279x56, top: 161px, #45556C, box-shadow #AC7F5E
/// - Resumo da semana: 342x83 em left: 24px, top: 251px
/// - Card Diário Pessoal (Frame 103): 163x171 em left: 24px, top: 360px (#F4F4F5, border 1px #0069A8)
/// - Card Chat Anônimo (Group 104): 163x171 em left: 203px, top: 360px (#F4F4F5, border 1px #0069A8)
/// - Card Canais de Apoio & FAQ (Frame 105): 342x171 em left: 24px, top: 547px (#F4F4F5, border 1px #0069A8)
/// - Botão Ajuda (CVV): 130x34 em left: 236px, top: 758px (#00A6F4, border-radius: 32px)
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

  Future<void> _openFeelingsScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryFeelingsView(controller: _diaryController),
      ),
    );
    if (result != null && mounted) {
      setState(() {});
    }
  }

  Future<void> _openReflectionScreen(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DiaryReflectionView(repository: _diaryController.repository),
      ),
    );
    // Recarrega para o resumo da semana mostrar o registro novo.
    if (saved == true && mounted) await _diaryController.loadEntries();
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

  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.messagesSquare,
                  size: 40,
                  color: Color(0xFF0069A8),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chat Anônimo',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Converse com a equipe de apoio da escola de forma 100% anônima e segura. Suas conversas não revelam seu nome ou identidade.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF52525B),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0069A8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFaqDialog() {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.shieldCheck,
                      color: Color(0xFF0069A8),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Canais de Apoio & FAQ',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18181B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFaqItem(
                  'Como funciona o anonimato?',
                  'Você escolhe um codinome e avatar. Nenhum dado pessoal é transmitido.',
                ),
                _buildFaqItem(
                  'Como falar com o psicólogo da escola?',
                  'Você pode solicitar atendimento anônimo ou agendar pelo canal de apoio escolar.',
                ),
                _buildFaqItem(
                  'O que fazer em emergências?',
                  'Disque 188 gratuitamente para falar com o CVV a qualquer momento.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0069A8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF71717A),
            ),
          ),
        ],
      ),
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

    final cleanAvatar = avatarPath.startsWith('assets/')
        ? avatarPath
        : 'assets/avatars/$avatarPath';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
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
                  // 1. Rectangle 3 (Top Header)
                  // width: 390px, height: 140px, left: 0, top: 0, background: #00A6F4
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 390,
                    height: 140,
                    child: Container(
                      color: const Color(0xFF00A6F4),
                    ),
                  ),

                  // 2. Frame 100 (Header Content)
                  // width: 352px, height: 72px, left: calc(50% - 352px/2), top: 44px
                  Positioned(
                    left: (390 - 352) / 2,
                    top: 44,
                    width: 352,
                    height: 72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // "Olá, Panda!" (or student nickname)
                        // width: 88px, height: 72px, Poppins 300 24px line-height 36px, color: #FAFAFA
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Olá,\n$nickname!',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                height: 36 / 24,
                                color: const Color(0xFFFAFAFA),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Frame 100 (Avatar container)
                        // width: 64px, height: 64px, background: #FAFAFA, border-radius: 16px, padding: 8px
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SvgPicture.asset(
                            cleanAvatar,
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Frame 101 - "Como está sua mente hoje?"
                  // width: 279px, height: 56px, left: calc(50% - 279px/2 + 0.5px), top: 161px
                  // background: #45556C, box-shadow: 0px 1px 10px #AC7F5E, border-radius: 16px
                  Positioned(
                    left: (390 - 279) / 2 + 0.5,
                    top: 161,
                    width: 279,
                    height: 56,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('button_como_esta_sua_mente'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openFeelingsScreen(context),
                        child: Container(
                          width: 279,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF45556C),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFAC7F5E).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Como está sua mente hoje?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFAFAFA),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Resumo da semana
                  // width: 342px, height: 83px, left: 24px, top: 251px
                  Positioned(
                    left: 24,
                    top: 251,
                    width: 342,
                    height: 83,
                    child: AnimatedBuilder(
                      animation: _diaryController,
                      builder: (context, _) {
                        return Container(
                          width: 342,
                          height: 83,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0069A8).withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.calendar,
                                          size: 14,
                                          color: Color(0xFF0069A8),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Resumo da semana',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF18181B),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _diaryController.entries.isNotEmpty
                                        ? '${_diaryController.entries.length} registro(s)'
                                        : 'Nenhum registro',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ),
                              _buildWeekDaysRow(_diaryController),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 5. Diário Pessoal (Frame 103)
                  // width: 163px, height: 171px, left: 24px, top: 360px
                  // background: #F4F4F5, border: 1px solid #0069A8, border-radius: 16px
                  Positioned(
                    left: 24,
                    top: 360,
                    width: 163,
                    height: 171,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('card_diario_pessoal'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openReflectionScreen(context),
                        child: Container(
                          width: 163,
                          height: 171,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0069A8),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0069A8).withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  LucideIcons.bookHeart,
                                  size: 20,
                                  color: Color(0xFF0069A8),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Diário Pessoal',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Registre sentimentos e reflexões',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF71717A),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 6. Chat Anônimo (Group 104)
                  // width: 163px, height: 171px, left: 203px, top: 360px
                  // background: #F4F4F5, border: 1px solid #0069A8, border-radius: 16px
                  Positioned(
                    left: 203,
                    top: 360,
                    width: 163,
                    height: 171,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('card_chat_anonimo'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: _showChatDialog,
                        child: Container(
                          width: 163,
                          height: 171,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0069A8),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0069A8).withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  LucideIcons.messagesSquare,
                                  size: 20,
                                  color: Color(0xFF0069A8),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Chat Anônimo',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Espaço acolhedor e sigiloso',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF71717A),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 7. Canais de Apoio & FAQ (Frame 105)
                  // width: 342px, height: 171px, left: 24px, top: 547px
                  // background: #F4F4F5, border: 1px solid #0069A8, border-radius: 16px
                  Positioned(
                    left: 24,
                    top: 547,
                    width: 342,
                    height: 171,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('card_canais_apoio_faq'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: _showFaqDialog,
                        child: Container(
                          width: 342,
                          height: 171,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0069A8),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0069A8)
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      LucideIcons.shieldCheck,
                                      size: 20,
                                      color: Color(0xFF0069A8),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    size: 18,
                                    color: Color(0xFF0069A8),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                'Canais de Apoio & FAQ',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF18181B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dúvidas frequentes, rede de apoio escolar e canais comunitários 24h.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF71717A),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 8. Ajuda (CVV)
                  // width: 130px, height: 34px, left: 236px, top: 758px
                  // background: #00A6F4, border-radius: 32px
                  Positioned(
                    left: 236,
                    top: 758,
                    width: 130,
                    height: 34,
                    child: Material(
                      color: const Color(0xFF00A6F4),
                      borderRadius: BorderRadius.circular(32),
                      elevation: 2,
                      child: InkWell(
                        key: const Key('button_ajuda_cvv'),
                        borderRadius: BorderRadius.circular(32),
                        onTap: _showCvvDialog,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.phone,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ajuda (CVV)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  /// Builds row representing the 7 days of the week with mood status
  Widget _buildWeekDaysRow(DiaryController controller) {
    const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final now = DateTime.now();
    final todayWeekday = now.weekday % 7; // 0 for Sunday, 1 for Monday...

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isToday = index == todayWeekday;
        // Check if there is an entry matching this day in the last 7 days
        Humor? dayHumor;
        for (final entry in controller.entries) {
          final diff = now.difference(entry.dataHora).inDays;
          if (diff < 7 && (entry.dataHora.weekday % 7) == index) {
            dayHumor = entry.humor;
            break;
          }
        }

        return Column(
          children: [
            Text(
              days[index],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                color: isToday ? const Color(0xFF0069A8) : const Color(0xFF71717A),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dayHumor != null
                    ? dayHumor.wheelColor
                    : (isToday
                        ? const Color(0xFF0069A8).withValues(alpha: 0.15)
                        : const Color(0xFFE4E4E7)),
                border: isToday
                    ? Border.all(color: const Color(0xFF0069A8), width: 1.5)
                    : null,
              ),
              child: dayHumor != null
                  ? Center(
                      child: Text(
                        dayHumor.emoji,
                        style: const TextStyle(fontSize: 10),
                      ),
                    )
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
