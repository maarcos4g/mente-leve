import 'package:flutter/material.dart';
import 'package:mente_leve/modules/psychologist/auth/auth_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/widgets/input_text_field/input_text_field.dart';
import 'package:mente_leve/shared/widgets/auth/profile_auth_scaffold.dart';
import 'package:provider/provider.dart';

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

  Future<void> _submit() async {
    final auth = context.read<AuthNotifier>();
    if (auth.isLoading || !controller.validate()) return;
    final error = await auth.signInAsInstitutional(
      email: emailController.text.trim(),
      password: passwordController.text,
      role: Role.psychologist,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/psychologist/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileAuthScaffold(
      formKey: controller.formKey,
      isLoading: context.watch<AuthNotifier>().isLoading,
      subtitle: 'Acesso exclusivo para equipe\npedagógica e psicólogos.',
      illustration: 'assets/images/psychologist.png',
      onSubmit: _submit,
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
