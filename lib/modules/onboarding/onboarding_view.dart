import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';
import 'package:mente_leve/shared/widgets/button/button_widget.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(color: Colors.white),
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(color: Colors.blue),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 120,
              horizontal: 35.0,
            ),
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: 166, height: 33),
                SizedBox(height: 92),
                Image.asset(
                  'assets/images/bro.png',
                  width: 280,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 64),
                Text(
                  'Seu porto seguro, direto no seu bolso',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: TailwindColors.zinc50,
                  ),
                ),
                SizedBox(height: 80),
                ButtonWidget(
                  label: "Entrar como aluno",
                  textStyle: AppTextStyles.buttonHeading.copyWith(
                    color: TailwindColors.sky700,
                  ),
                  icon: LucideIcons.graduationCap,
                  backgroundColor: TailwindColors.zinc50,
                  onPressed: () {},
                ),
                SizedBox(height: 48),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: 256,
                            minWidth: double.infinity,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.0),
                            ),
                          ),
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 16,
                            children: [
                              Container(
                                width: 50,
                                height: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: TailwindColors.zinc500,
                                ),
                              ),
                              Text(
                                'Com qual perfil gostaria de acessar?',
                                style: AppTextStyles.captionMedium.copyWith(
                                  color: TailwindColors.zinc950,
                                ),
                              ),
                              SizedBox(height: 8),
                              ButtonWidget(
                                label: "Gestão educacional",
                                textStyle: AppTextStyles.buttonHeading.copyWith(
                                  color: TailwindColors.zinc50,
                                ),
                                icon: LucideIcons.graduationCap,
                                backgroundColor: TailwindColors.sky600,
                                onPressed: () {},
                              ),
                              ButtonWidget(
                                label: "Responsável",
                                textStyle: AppTextStyles.buttonHeading.copyWith(
                                  color: TailwindColors.zinc50,
                                ),
                                icon: LucideIcons.userLock,
                                backgroundColor: TailwindColors.sky600,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'Acessar com outro tipo de perfil',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: TailwindColors.zinc50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
