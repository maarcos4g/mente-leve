import 'package:flutter/material.dart';
import 'package:mente_leve/modules/onboarding/onboarding_view.dart';
import 'package:mente_leve/modules/parents/auth/auth_view.dart';
import 'package:mente_leve/modules/psychologist/auth/auth_view.dart';
import 'package:mente_leve/modules/splash/splash_view.dart';
import 'package:mente_leve/modules/student/auth/auth_view.dart';
import 'package:mente_leve/modules/student/auth/select_avatar_view.dart';
import 'package:mente_leve/modules/student/home/student_home_view.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mente Leve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A1A1A),
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/onboarding': (context) => const OnboardingView(),
        '/auth/student': (context) => const StudentAuthView(),
        '/auth/avatar': (context) => const SelectAvatarView(),
        '/student/home': (context) => const StudentHomeView(),
        '/auth/psychologist': (context) => const PsychologistAuthView(),
        '/auth/parents': (context) => const ParentsAuthView(),
      },
    );
  }
}
