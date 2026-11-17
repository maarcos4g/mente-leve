import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

void main() {
  group('Humor Enum Tests', () {
    test('contains all 6 specified emotions from domain model', () {
      expect(Humor.values.length, 6);
      expect(Humor.values, containsAll([
        Humor.feliz,
        Humor.neutro,
        Humor.triste,
        Humor.ansioso,
        Humor.comRaiva,
        Humor.cansado,
      ]));
    });

    test('labels match expected Portuguese names', () {
      expect(Humor.feliz.label, 'Feliz');
      expect(Humor.neutro.label, 'Neutro');
      expect(Humor.triste.label, 'Triste');
      expect(Humor.ansioso.label, 'Ansioso');
      expect(Humor.comRaiva.label, 'Com Raiva');
      expect(Humor.cansado.label, 'Cansado');
    });

    test('emojis match expected glyphs', () {
      expect(Humor.feliz.emoji, '😊');
      expect(Humor.neutro.emoji, '😐');
      expect(Humor.triste.emoji, '😢');
      expect(Humor.ansioso.emoji, '😰');
      expect(Humor.comRaiva.emoji, '😡');
      expect(Humor.cansado.emoji, '😴');
    });

    test('colors match Tailwind palette', () {
      expect(Humor.feliz.color, TailwindColors.amber500);
      expect(Humor.neutro.color, TailwindColors.sky500);
      expect(Humor.triste.color, TailwindColors.blue600);
      expect(Humor.ansioso.color, TailwindColors.violet500);
      expect(Humor.comRaiva.color, TailwindColors.red500);
      expect(Humor.cansado.color, TailwindColors.slate500);
    });

    test('comforting messages are non-empty for all moods', () {
      for (final humor in Humor.values) {
        expect(humor.comfortingMessage, isNotEmpty);
      }
    });

    test('isCritical identifies vulnerable emotions requiring extra care', () {
      expect(Humor.triste.isCritical, isTrue);
      expect(Humor.ansioso.isCritical, isTrue);
      expect(Humor.comRaiva.isCritical, isTrue);

      expect(Humor.feliz.isCritical, isFalse);
      expect(Humor.neutro.isCritical, isFalse);
      expect(Humor.cansado.isCritical, isFalse);
    });
  });
}
