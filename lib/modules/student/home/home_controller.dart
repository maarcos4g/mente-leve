import 'package:flutter/material.dart';
import 'package:mente_leve/shared/widgets/home/mood_bubble.dart';

class HomeController {
  HomeController({String? nickname, String? avatar})
    : nickname = (nickname == null || nickname.trim().isEmpty)
          ? defaultNickname
          : nickname.trim(),
      avatar = avatar ?? defaultAvatar;

  static const defaultNickname = 'Panda';
  static const defaultAvatar = 'panda.svg';

  /// Destinos dos atalhos. Cada rota só abre quando a etapa dona dela a
  /// registrar em `AppWidget.routes` (diário: etapa 2, FAQ: etapa 4,
  /// denúncia anônima: etapa 5).
  static const diaryRoute = '/diary';
  static const reportRoute = '/report';
  static const faqRoute = '/faq';

  final String nickname;
  final String avatar;

  String get avatarAsset => 'assets/avatars/$avatar';

  /// Resumo da semana: dados de exemplo, na ordem do protótipo. Será
  /// substituído pelos registros do diário quando a etapa 2 existir.
  static const sampleWeekMoods = <MoodVisual>[
    MoodVisual(
      asset: 'assets/home/mood_happy.svg',
      glowColor: Color(0xFF05DF72),
    ),
    MoodVisual(asset: 'assets/home/mood_sad.svg', glowColor: Color(0xFF00D3F3)),
    // Humor em destaque: opacidade total e brilho escuro.
    MoodVisual(
      asset: 'assets/home/mood_neutral.svg',
      glowColor: Color(0xFF3B3B3B),
      opacity: 1,
    ),
    MoodVisual(
      asset: 'assets/home/mood_confused.svg',
      glowColor: Color(0xFFC40ECE),
    ),
    MoodVisual(
      asset: 'assets/home/mood_angry.svg',
      glowColor: Color(0xFFFF0000),
    ),
  ];

  List<MoodVisual> get weekMoods => sampleWeekMoods;

  /// Abre [route] se ela já estiver registrada; senão avisa que ainda não
  /// está disponível.
  void open(
    BuildContext context,
    String route, {
    required Set<String> availableRoutes,
  }) {
    if (availableRoutes.contains(route)) {
      Navigator.of(context).pushNamed(route);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Disponível em breve.')));
  }
}
