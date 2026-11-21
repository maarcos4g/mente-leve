import 'package:flutter/material.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_controller.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';
import 'package:mente_leve/modules/student/home/mood_scale.dart';
import 'package:mente_leve/shared/widgets/home/mood_bubble.dart';

class HomeController {
  HomeController({String? nickname, String? avatar, DiaryRepository? repository})
    : nickname = (nickname == null || nickname.trim().isEmpty)
          ? defaultNickname
          : nickname.trim(),
      avatar = avatar ?? defaultAvatar,
      repository = repository ?? DiaryController.defaultRepository;

  static const defaultNickname = 'Panda';
  static const defaultAvatar = 'panda.svg';

  /// Destinos dos atalhos. Cada rota só abre quando a etapa dona dela a
  /// registrar em `AppWidget.routes` (diário: etapa 2, FAQ: etapa 4,
  /// denúncia anônima: etapa 5).
  static const diaryRoute = '/diary';
  static const diaryReflectionRoute = '/diary/reflection';
  static const reportRoute = '/report';
  static const faqRoute = '/faq';

  final String nickname;
  final String avatar;

  String get avatarAsset => 'assets/avatars/$avatar';

  /// Repositório do diário (lido para montar a escala da semana).
  final DiaryRepository repository;

  /// Escala atual (1 a 5) dos humores da última semana.
  MoodScale scale = MoodScale.empty;

  /// Os cinco cérebros na ordem da escala, do nível 1 ao 5, com o brilho de
  /// cada humor (aparência fora de destaque).
  static const scaleNames = ['Raiva', 'Triste', 'Confuso', 'Neutro', 'Feliz'];

  static const scaleMoods = <MoodVisual>[
    MoodVisual(
      asset: 'assets/home/mood_angry.svg',
      glowColor: Color(0xFFFF0000),
    ),
    MoodVisual(asset: 'assets/home/mood_sad.svg', glowColor: Color(0xFF00D3F3)),
    MoodVisual(
      asset: 'assets/home/mood_confused.svg',
      glowColor: Color(0xFFC40ECE),
    ),
    MoodVisual(
      asset: 'assets/home/mood_neutral.svg',
      glowColor: Color(0xFF3B3B3B),
    ),
    MoodVisual(
      asset: 'assets/home/mood_happy.svg',
      glowColor: Color(0xFF05DF72),
    ),
  ];

  /// Cor do brilho do cérebro que indica o nível atual.
  static const activeGlow = Color(0xFF05DF72);

  /// Cérebros do resumo: o do nível atual fica com opacidade total e brilho
  /// verde; os demais a 30%. Sem registros na semana, nenhum é destacado.
  List<MoodVisual> get weekMoods {
    final level = scale.level;
    return [
      for (var i = 0; i < scaleMoods.length; i++)
        if (level == i + 1)
          MoodVisual(
            asset: scaleMoods[i].asset,
            glowColor: activeGlow,
            opacity: 1,
            label: 'Escala ${i + 1} de 5: ${scaleNames[i]} (nível atual)',
          )
        else
          MoodVisual(
            asset: scaleMoods[i].asset,
            glowColor: scaleMoods[i].glowColor,
            label: 'Escala ${i + 1} de 5: ${scaleNames[i]}',
          ),
    ];
  }

  /// Recalcula a escala a partir dos registros salvos no diário.
  Future<void> loadScale({DateTime? now}) async {
    final entries = await repository.getAll();
    scale = MoodScale.fromEntries(entries, now ?? DateTime.now());
  }

  /// Abre [route] se ela já estiver registrada; senão avisa que ainda não
  /// está disponível.
  Future<void> open(
    BuildContext context,
    String route, {
    required Set<String> availableRoutes,
  }) async {
    if (availableRoutes.contains(route)) {
      await Navigator.of(context).pushNamed(route);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Disponível em breve.')));
  }
}
