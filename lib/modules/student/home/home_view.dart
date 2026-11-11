import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';
import 'package:mente_leve/shared/widgets/home/home_feature_card.dart';
import 'package:mente_leve/shared/widgets/home/home_header.dart';
import 'package:mente_leve/shared/widgets/home/mood_prompt_card.dart';
import 'package:mente_leve/shared/widgets/home/week_summary.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({
    super.key,
    this.nickname,
    this.avatar,
    this.availableRoutes = const {},
    this.onCvvPressed,
  });

  final String? nickname;
  final String? avatar;

  /// Rotas já registradas no app (ver `AppWidget.routes`).
  final Set<String> availableRoutes;

  /// Troca a ação do botão CVV (testes). Por padrão disca 188.
  final VoidCallback? onCvvPressed;

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  late final HomeController controller = HomeController(
    nickname: widget.nickname,
    avatar: widget.avatar,
  );

  void _open(String route) =>
      controller.open(context, route, availableRoutes: widget.availableRoutes);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.zinc50,
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                // Espaço para o botão CVV não cobrir o último card.
                padding: const EdgeInsets.only(bottom: 102),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeader(
                      nickname: controller.nickname,
                      avatarAsset: controller.avatarAsset,
                    ),
                    const SizedBox(height: 21),
                    Center(
                      child: MoodPromptCard(
                        onTap: () => _open(HomeController.diaryRoute),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: WeekSummary(moods: controller.weekMoods),
                    ),
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: HomeFeatureCard(
                              title: 'Diário\nPessoal',
                              illustrationAsset:
                                  'assets/home/diary_illustration.svg',
                              illustrationSize: const Size(121, 92),
                              illustrationOffset: const Offset(21, 78),
                              onTap: () =>
                                  _open(HomeController.diaryReflectionRoute),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: HomeFeatureCard(
                              title: 'Chat\nAnônimo',
                              illustrationAsset:
                                  'assets/home/chat_illustration.svg',
                              illustrationSize: const Size(121, 91),
                              illustrationOffset: const Offset(21, 78),
                              onTap: () => _open(HomeController.reportRoute),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: HomeFeatureCard(
                        semanticLabel: 'Canais de Apoio e FAQ',
                        illustrationAsset: 'assets/home/faq_illustration.svg',
                        illustrationSize: const Size(211, 116.5),
                        illustrationOffset: const Offset(127, 50),
                        onTap: () => _open(HomeController.faqRoute),
                        titleWidget: const _FaqTitle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 52,
              child: CvvButton(onPressed: widget.onCvvPressed),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Canais de Apoio" alinhado à esquerda e "& FAQ" alinhado à direita, como
/// no protótipo.
class _FaqTitle extends StatelessWidget {
  const _FaqTitle();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.buttonHeading.copyWith(color: Colors.black);
    return Stack(
      children: [
        Positioned(
          left: 40,
          top: 30,
          child: Text('Canais de Apoio', style: style, softWrap: false),
        ),
        Positioned(
          left: 1,
          top: 51,
          width: 135,
          child: Text('& FAQ', style: style, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
