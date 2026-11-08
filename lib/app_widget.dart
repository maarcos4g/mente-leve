import 'package:flutter/material.dart';
import 'package:mente_leve/modules/onboarding/onboarding_view.dart';
import 'package:mente_leve/modules/parents/auth/auth_view.dart';
import 'package:mente_leve/modules/psychologist/auth/auth_view.dart';
import 'package:mente_leve/modules/splash/splash_view.dart';
import 'package:mente_leve/modules/student/auth/auth_view.dart';
import 'package:mente_leve/modules/student/auth/select_avatar_view.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/modules/student/home/home_view.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  /// Rotas nomeadas do app. Telas de outras etapas (diário, FAQ, denúncia)
  /// entram aqui quando existirem; a Home usa as chaves para saber o que abrir.
  static final Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashView(),
    '/onboarding': (context) => const OnboardingView(),
    '/auth/student': (context) => const StudentAuthView(),
    '/auth/avatar': (context) => const SelectAvatarView(),
    '/auth/psychologist': (context) => const PsychologistAuthView(),
    '/auth/parents': (context) => const ParentsAuthView(),
    '/home': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return HomeView(
        nickname: args is HomeArguments ? args.nickname : null,
        avatar: args is HomeArguments ? args.avatar : null,
        availableRoutes: routes.keys.toSet(),
      );
    },
  };

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
      routes: routes,
    );
  }
}
