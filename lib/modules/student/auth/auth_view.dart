import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';
import 'package:mente_leve/shared/widgets/button/button_widget.dart';

class StudentAuthView extends StatefulWidget {
  const StudentAuthView({super.key});

  @override
  State<StudentAuthView> createState() => _StudentAuthViewState();
}

class _StudentAuthViewState extends State<StudentAuthView> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  String avatarPath = 'panda.svg';

  @override
  Widget build(BuildContext context) {
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
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: 130,
            top: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/auth/avatar',
                  );
                  final selected = result is String ? result : null;
                  if (selected != null && mounted) {
                    setState(() => avatarPath = selected);
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SvgPicture.asset(
                        'assets/avatars/$avatarPath',
                        width: 72,
                        height: 72,
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            color: Color(0xFF71717A), // TailwindColors.zinc500
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Olá!',
                style: AppTextStyles.titleBoldHeading.copyWith(
                  color: TailwindColors.zinc950,
                ),
              ),
              Text(
                'Como podemos te chamar?',
                style: AppTextStyles.buttonHeading.copyWith(
                  color: TailwindColors.zinc950,
                ),
              ),
              SizedBox(height: 78),
              Container(
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escolha um codinome',
                      style: AppTextStyles.captionBody,
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Ex.: Panda',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: TailwindColors.zinc400),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        isDense: true,
                      ),
                      validator: (String? value) =>
                          value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 72),
              ButtonWidget(
                label: "Continuar",
                textStyle: AppTextStyles.buttonHeading.copyWith(
                  color: TailwindColors.zinc50,
                ),
                backgroundColor: TailwindColors.sky600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
