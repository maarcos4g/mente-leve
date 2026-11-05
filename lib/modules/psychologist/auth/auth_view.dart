import 'package:flutter/material.dart';
import 'package:mente_leve/modules/psychologist/auth/auth_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/widgets/input_text_field/input_text_field.dart';
import 'package:mente_leve/shared/widgets/auth/profile_auth_scaffold.dart';

class PsychologistAuthView extends StatefulWidget {
  const PsychologistAuthView({super.key});

  @override
  State<PsychologistAuthView> createState() => _PsychologistAuthViewState();
}

class _PsychologistAuthViewState extends State<PsychologistAuthView> {
  final controller = PsychologistAuthController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileAuthScaffold(
      formKey: controller.formKey,
      subtitle: 'Acesso exclusivo para equipe\npedagógica e psicólogos.',
      illustration: 'assets/images/psychologist.png',
      onSubmit: () {
        if (controller.login()) {
          // TODO: integrar autenticação.
        }
      },
      fields: [
        InputTextField(
          controller: emailController,
          hint: 'Seu e-mail institucional',
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: controller.validateEmail,
        ),
        InputTextField(
          controller: passwordController,
          hint: 'Sua senha',
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          validator: controller.validatePassword,
        ),
      ],
    );
  }
}
