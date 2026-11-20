import 'package:flutter/material.dart';
import 'package:mente_leve/shared/widgets/profile/profile_sheet.dart';

class PsychologistHomeView extends StatelessWidget {
  const PsychologistHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => showProfileSheet(context),
          ),
        ],
      ),
    );
  }
}
