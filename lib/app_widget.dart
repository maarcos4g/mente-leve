import 'package:flutter/material.dart';
import 'package:mente_leve/modules/onboarding/onboarding_view.dart';
import 'package:mente_leve/modules/parents/auth/auth_view.dart';
import 'package:mente_leve/modules/parents/home/guide_detail_view.dart';
import 'package:mente_leve/modules/parents/home/home_view.dart';
import 'package:mente_leve/modules/psychologist/auth/auth_view.dart';
import 'package:mente_leve/modules/psychologist/chat/psychologist_chat_view.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_view.dart';
import 'package:mente_leve/modules/psychologist/guides/psychologist_guides_view.dart';
import 'package:mente_leve/modules/psychologist/home/home_view.dart';
import 'package:mente_leve/modules/psychologist/reports/reports_view.dart';
import 'package:mente_leve/modules/splash/splash_view.dart';
import 'package:mente_leve/modules/student/auth/auth_view.dart';
import 'package:mente_leve/modules/student/auth/select_avatar_view.dart';
import 'package:mente_leve/modules/student/chat/anonymous_chat_view.dart';
import 'package:mente_leve/modules/student/diary/diary_feelings_view.dart';
import 'package:mente_leve/modules/student/diary/diary_reflection_view.dart';
import 'package:mente_leve/modules/student/faq/student_faq_view.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/modules/student/home/home_view.dart';
import 'package:mente_leve/modules/student/official_channels/official_channels_view.dart';
import 'package:mente_leve/modules/student/support_trigger/support_modal_view.dart';
import 'package:mente_leve/shared/app_update/app_update_controller.dart';
import 'package:mente_leve/shared/app_update/app_update_prompter.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_overlay.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatefulWidget {
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
    HomeController.diaryRoute: (context) => DiaryFeelingsView(
      onMoodSaved: (context) =>
          _offerSupport(context, replaceCurrentRoute: true),
    ),
    HomeController.diaryReflectionRoute: (context) =>
        const DiaryReflectionView(onMoodSaved: _offerSupport),
    HomeController.faqRoute: (context) =>
        StudentFaqView(availableRoutes: routes.keys.toSet()),
    OfficialChannelsView.routeName: (context) => const OfficialChannelsView(),
    HomeController.reportRoute: (context) => const AnonymousChatView(),
    '/parents/home': (context) {
      final session = context.watch<AuthNotifier>().session;
      final user = session is InstitutionalSession ? session.user : null;
      return ParentsHomeView(user: user);
    },
    GuideDetailView.routeName: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is! GuideDetailArgs) {
        return const ParentsHomeView();
      }
      return GuideDetailView(guide: args.guide, colorIndex: args.colorIndex);
    },
    '/psychologist/home': (context) {
      final session = context.watch<AuthNotifier>().session;
      final user = session is InstitutionalSession ? session.user : null;
      return PsychologistHomeView(user: user);
    },
    PsychologistFaqView.routeName: (context) => const PsychologistFaqView(),
    PsychologistGuidesView.routeName:
        (context) => const PsychologistGuidesView(),
    ReportsView.routeName: (context) => const ReportsView(),
    PsychologistChatView.routeName: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as ReportChatArgs;
      return PsychologistChatView(args: args);
    },
  };

  /// Avalia o gatilho de apoio (RN11) depois que o humor foi salvo.
  static Future<String?> _offerSupport(
    BuildContext context, {
    bool replaceCurrentRoute = false,
  }) {
    final session = context.read<AuthNotifier>().session;
    final user = session is StudentSessionModel ? session.user : null;
    return showSupportModalIfNeeded(
      context,
      availableRoutes: routes.keys.toSet(),
      avatar: user?.avatar,
      replaceCurrentRoute: replaceCurrentRoute,
    );
  }

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final CvvRouteObserver _routeObserver = CvvRouteObserver();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppUpdatePrompter _updatePrompter;

  @override
  void initState() {
    super.initState();
    // Atualização in-app (GitHub Releases): verifica ao iniciar e mostra o
    // modal quando o app chegar numa tela inicial.
    _updatePrompter = AppUpdatePrompter(
      controller: context.read<AppUpdateController>(),
      navigatorKey: _navigatorKey,
      currentRoute: _routeObserver.currentRoute,
      homeRoutes: const {
        '/student/home',
        '/parents/home',
        '/psychologist/home',
      },
    )..start();
  }

  @override
  void dispose() {
    _updatePrompter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Mente Leve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A1A1A),
        primarySwatch: Colors.blue,
      ),
      // Botão de emergência (CVV 188) visível apenas nas telas funcionais do aluno.
      builder: (context, child) => CvvOverlay(
        observer: _routeObserver,
        child: child ?? const SizedBox.shrink(),
      ),
      navigatorObservers: [_routeObserver],
      initialRoute: '/splash',
      routes: AppWidget.routes,
    );
  }
}
