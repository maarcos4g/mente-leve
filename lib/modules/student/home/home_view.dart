import 'package:flutter/material.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:provider/provider.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            final nav = Navigator.of(context);
            await context.read<AuthNotifier>().signOut();
            nav.pushNamedAndRemoveUntil('/onboarding', (_) => false);
          },
          child: const Text('Sair'),
        ),
      ),
    );
  }
}