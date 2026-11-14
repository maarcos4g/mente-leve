import 'package:flutter/material.dart';
import 'package:mente_leve/modules/onboarding/onboarding_view.dart';
import 'package:mente_leve/modules/parents/auth/auth_view.dart';
import 'package:mente_leve/modules/parents/home/home_view.dart';
import 'package:mente_leve/modules/psychologist/auth/auth_view.dart';
import 'package:mente_leve/modules/psychologist/home/home_view.dart';
import 'package:mente_leve/modules/splash/splash_view.dart';
import 'package:mente_leve/modules/student/auth/auth_view.dart';
import 'package:mente_leve/modules/student/auth/select_avatar_view.dart';
import 'package:mente_leve/modules/student/home/home_view.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_overlay.dart';
import 'package:provider/provider.dart';

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
    '/student/home': (context) {
      final session = context.watch<AuthNotifier>().session;
      final user = session is StudentSessionModel ? session.user : null;
      return StudentHomeView(
        nickname: user?.nickname,
        avatar: user?.avatar,
        availableRoutes: routes.keys.toSet(),
      );
    },
    '/parents/home': (context) => ParentsHomeView(),
    '/psychologist/home': (context) => PsychologistHomeView(),
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
      // Botão de emergência (CVV 188) visível em todas as telas.
      builder: (context, child) =>
          CvvOverlay(child: child ?? const SizedBox.shrink()),
      initialRoute: '/splash',
      routes: routes,
    );
  }
}
