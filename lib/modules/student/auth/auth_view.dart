import 'package:flutter/material.dart';
import 'package:mente_leve/modules/student/auth/auth_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';
import 'package:mente_leve/shared/widgets/button/button_widget.dart';
import 'package:mente_leve/shared/widgets/input_text_field/input_text_field.dart';
import 'package:provider/provider.dart';

class StudentAuthView extends StatefulWidget {
  const StudentAuthView({super.key});

  @override
  State<StudentAuthView> createState() => _StudentAuthViewState();
}

class _StudentAuthViewState extends State<StudentAuthView> {
  final controller = StudentAuthController();

  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthNotifier>();
    if (auth.isLoading || !controller.submit()) return;
    final error = await auth.signInAsStudent(controller.profile);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/student/home', (_) => false);
  }


  @override
  Widget build(BuildContext context) {

  final loading = context.watch<AuthNotifier>().isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 130,
            top: 20,
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/auth/avatar',
                    );
                    final selected = result is String ? result : null;
                    if (selected != null && mounted) {
                      setState(() => controller.onChange(avatar: selected));
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TailwindColors.sky500,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SvgPicture.asset(
                          'assets/avatars/${controller.avatarPath}',
                          width: 72,
                          height: 72,
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: TailwindColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TailwindColors.sky500,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              LucideIcons
                                  .squarePen, // Pode substituir pelo LucideIcons.edit
                              size: 16,
                              color: TailwindColors
                                  .zinc950, // TailwindColors.zinc500
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 44),
                Text(
                  'Olá!',
                  style: AppTextStyles.titleBoldHeading.copyWith(
                    color: TailwindColors.zinc950,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Como podemos te chamar?',
                  style: AppTextStyles.buttonHeading.copyWith(
                    color: TailwindColors.zinc950,
                  ),
                ),
                SizedBox(height: 110),
                InputTextField(
                  controller: nameController,
                  label: 'Escolha um codinome',
                  hint: 'Ex.: Panda',
                  onChanged: (value) => controller.onChange(name: value),
                  validator: controller.validateNickname,
                ),
                SizedBox(height: 104),
                ButtonWidget(
                  label: loading ? 'Entrando...' : "Continuar",
                  textStyle: AppTextStyles.buttonHeading.copyWith(
                    color: TailwindColors.zinc50,
                  ),
                  backgroundColor: TailwindColors.sky600,
                  onPressed: loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
