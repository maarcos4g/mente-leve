import 'package:flutter/material.dart';
import 'package:mente_leve/modules/parents/auth/auth_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/widgets/input_text_field/input_text_field.dart';
import 'package:mente_leve/shared/widgets/auth/profile_auth_scaffold.dart';

class ParentsAuthView extends StatefulWidget {
  const ParentsAuthView({super.key});

  @override
  State<ParentsAuthView> createState() => _ParentsAuthViewState();
}

class _ParentsAuthViewState extends State<ParentsAuthView> {
  final controller = ParentsAuthController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileAuthScaffold(
      formKey: controller.formKey,
      subtitle: 'Para acessar, por favor insira seus dados.',
      illustration: 'assets/images/parents.png',
      onSubmit: () {
        if (controller.login()) {
          // integrar autenticação.
        }
      },
      fields: [
        InputTextField(
          controller: idController,
          hint: 'Número de identificação',
          prefixIcon: LucideIcons.idCard,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: controller.validateIdentification,
        ),
        InputTextField(
          controller: passwordController,
          hint: 'Senha fornecida pela escola',
          prefixIcon: LucideIcons.lock,
          obscureText: true,
          validator: controller.validatePassword,
        ),
      ],
    );
  }
}
