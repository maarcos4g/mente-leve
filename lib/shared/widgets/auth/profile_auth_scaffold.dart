import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';
import 'package:mente_leve/shared/widgets/button/button_widget.dart';

/// Estrutura base das telas de login de perfis (psicólogo e responsável):
/// cabeçalho azul com logo, título, subtítulo, ilustração, campos, botão
/// "Entrar" e link "Voltar".
class ProfileAuthScaffold extends StatelessWidget {
  const ProfileAuthScaffold({
    super.key,
    required this.formKey,
    required this.subtitle,
    required this.illustration,
    required this.fields,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String subtitle;

  /// Caminho do asset da ilustração (ex.: `assets/images/parents.png`).
  final String illustration;
  final List<Widget> fields;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TailwindColors.zinc50,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 140,
              color: TailwindColors.sky500,
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Image.asset(
                'assets/images/logo2.png',
                width: 166,
                height: 33,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Olá!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleBoldHeading.copyWith(
                        color: TailwindColors.zinc950,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.captionBody.copyWith(
                        color: TailwindColors.zinc700,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        illustration,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          LucideIcons.image,
                          size: 64,
                          color: TailwindColors.zinc300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      fields[i],
                    ],
                    const SizedBox(height: 24),
                    ButtonWidget(
                      label: 'Entrar',
                      textStyle: AppTextStyles.buttonHeading.copyWith(
                        color: TailwindColors.zinc50,
                      ),
                      backgroundColor: TailwindColors.sky600,
                      onPressed: onSubmit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Voltar',
                            style: AppTextStyles.textXs.copyWith(
                              color: TailwindColors.zinc950,
                              decoration: TextDecoration.underline,
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
    );
  }
}
