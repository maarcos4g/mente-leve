import 'package:flutter/material.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Enumeração que representa os estados emocionais disponíveis no
/// Diário de Sentimentos por Emojis (RF01 / UC02).
///
/// Mapeada conforme especificação do modelo de domínio:
/// - docs/modelagem/02-diagrama-de-classes.md
/// - docs/modelagem/04-mapeamento-dart-firestore.md
enum Humor {
  feliz,
  neutro,
  triste,
  ansioso,
  comRaiva,
  cansado;

  /// Rótulo legível em português.
  String get label {
    switch (this) {
      case Humor.feliz:
        return 'Feliz';
      case Humor.neutro:
        return 'Neutro';
      case Humor.triste:
        return 'Triste';
      case Humor.ansioso:
        return 'Ansioso';
      case Humor.comRaiva:
        return 'Com Raiva';
      case Humor.cansado:
        return 'Cansado';
    }
  }

  /// Glifo de emoji amigável para interface do adolescente.
  String get emoji {
    switch (this) {
      case Humor.feliz:
        return '😊';
      case Humor.neutro:
        return '😐';
      case Humor.triste:
        return '😢';
      case Humor.ansioso:
        return '😰';
      case Humor.comRaiva:
        return '😡';
      case Humor.cansado:
        return '😴';
    }
  }

  /// Cor temática do Design System Tailwind.
  Color get color {
    switch (this) {
      case Humor.feliz:
        return TailwindColors.amber500;
      case Humor.neutro:
        return TailwindColors.sky500;
      case Humor.triste:
        return TailwindColors.blue600;
      case Humor.ansioso:
        return TailwindColors.violet500;
      case Humor.comRaiva:
        return TailwindColors.red500;
      case Humor.cansado:
        return TailwindColors.slate500;
    }
  }

  /// Fundo sutil para cartões e seleções.
  Color get backgroundColor {
    switch (this) {
      case Humor.feliz:
        return TailwindColors.amber50;
      case Humor.neutro:
        return TailwindColors.sky50;
      case Humor.triste:
        return TailwindColors.blue50;
      case Humor.ansioso:
        return TailwindColors.violet50;
      case Humor.comRaiva:
        return TailwindColors.red50;
      case Humor.cansado:
        return TailwindColors.slate100;
    }
  }

  /// Mensagem acolhedora validada pelo mascote de apoio (RF01 / Estudo de caso).
  String get comfortingMessage {
    switch (this) {
      case Humor.feliz:
        return 'Que bom te ver bem! Aproveite cada momento leve do seu dia.';
      case Humor.neutro:
        return 'Tudo bem ter um dia comum. Estou por aqui acompanhando você.';
      case Humor.triste:
        return 'Sinto muito que você esteja assim. Lembre-se: sentimentos difíceis também passam.';
      case Humor.ansioso:
        return 'Respire fundo devagar. Foque no agora, você está em um lugar seguro.';
      case Humor.comRaiva:
        return 'É válido sentir raiva. Dê uma pausa, tome uma água e respire com calma.';
      case Humor.cansado:
        return 'Seu corpo e mente precisam de carinho. Pegue leve com você hoje e descanse.';
    }
  }

  /// Indica se o humor reflete um estado de maior vulnerabilidade emocional,
  /// sugerindo apoio acolhedor ou encaminhamento discreto ao CVV 188.
  bool get isCritical =>
      this == Humor.triste || this == Humor.ansioso || this == Humor.comRaiva;
}
