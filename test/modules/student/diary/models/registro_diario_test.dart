import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';

void main() {
  group('RegistroDiario Model Tests', () {
    final now = DateTime(2026, 11, 8, 14, 30);

    test('creates valid instance with required fields', () {
      final registro = RegistroDiario(
        id: '1',
        humor: Humor.feliz,
        dataHora: now,
      );

      expect(registro.id, '1');
      expect(registro.humor, Humor.feliz);
      expect(registro.texto, isNull);
      expect(registro.pontosPositivos, isEmpty);
      expect(registro.dataHora, now);
      expect(registro.temTexto, isFalse);
    });

    test('temTexto returns true only when text is non-empty and non-blank', () {
      final withText = RegistroDiario(
        id: '2',
        humor: Humor.neutro,
        texto: 'Hoje o dia foi calmo.',
        dataHora: now,
      );
      expect(withText.temTexto, isTrue);

      final withBlankText = RegistroDiario(
        id: '3',
        humor: Humor.neutro,
        texto: '   ',
        dataHora: now,
      );
      expect(withBlankText.temTexto, isFalse);
    });

    test('toMap and fromMap serialize and deserialize correctly', () {
      final original = RegistroDiario(
        id: '100',
        humor: Humor.ansioso,
        texto: 'Muita lição de casa.',
        pontosPositivos: const ['Conversei com um amigo', 'Ouvi música'],
        dataHora: now,
      );

      final map = original.toMap();
      expect(map['id'], '100');
      expect(map['humor'], 'ansioso');
      expect(map['texto'], 'Muita lição de casa.');
      expect(map['pontosPositivos'], ['Conversei com um amigo', 'Ouvi música']);
      expect(map['dataHora'], now.toIso8601String());

      final restored = RegistroDiario.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.humor, original.humor);
      expect(restored.texto, original.texto);
      expect(restored.pontosPositivos, original.pontosPositivos);
      expect(restored.dataHora, original.dataHora);
    });

    test('editar returns modified instance keeping unedited fields', () {
      final original = RegistroDiario(
        id: '1',
        humor: Humor.cansado,
        texto: 'Muito sono.',
        pontosPositivos: const ['Dormi cedo'],
        dataHora: now,
      );

      final edited = original.editar(
        humor: Humor.feliz,
        texto: 'Descansei bem.',
      );

      expect(edited.id, '1');
      expect(edited.humor, Humor.feliz);
      expect(edited.texto, 'Descansei bem.');
      expect(edited.pontosPositivos, ['Dormi cedo']);
      expect(edited.dataHora, now);

      final cleared = edited.editar(clearTexto: true);
      expect(cleared.texto, isNull);
      expect(cleared.temTexto, isFalse);
    });

    test('copyWith supports clearTexto', () {
      final reg = RegistroDiario(
        id: '1',
        humor: Humor.neutro,
        texto: 'Nota',
        dataHora: now,
      );
      final updated = reg.copyWith(clearTexto: true);
      expect(updated.texto, isNull);
      expect(updated.temTexto, isFalse);
    });

    test('fromMap handles raw DateTime and int id robustly', () {
      final map = {
        'id': 12345,
        'humor': 'feliz',
        'dataHora': now, // DateTime directly instead of string
        'pontosPositivos': ['ponto1'],
      };

      final reg = RegistroDiario.fromMap(map);
      expect(reg.id, '12345');
      expect(reg.humor, Humor.feliz);
      expect(reg.dataHora, now);
      expect(reg.pontosPositivos, ['ponto1']);
    });

    test('equality and hashCode include pontosPositivos', () {
      final reg1 = RegistroDiario(
        id: '1',
        humor: Humor.feliz,
        dataHora: now,
      );

      final reg2 = RegistroDiario(
        id: '1',
        humor: Humor.feliz,
        dataHora: now,
      );

      final reg3 = RegistroDiario(
        id: '2',
        humor: Humor.triste,
        dataHora: now,
      );

      final regWithPontosA = RegistroDiario(
        id: '1',
        humor: Humor.feliz,
        pontosPositivos: const ['dormi bem'],
        dataHora: now,
      );

      final regWithPontosB = RegistroDiario(
        id: '1',
        humor: Humor.feliz,
        pontosPositivos: const ['conversei'],
        dataHora: now,
      );

      expect(reg1, equals(reg2));
      expect(reg1.hashCode, equals(reg2.hashCode));
      expect(reg1, isNot(equals(reg3)));

      // Verifies that different pontosPositivos produce inequality and distinct hash codes
      expect(regWithPontosA, isNot(equals(regWithPontosB)));
      expect(regWithPontosA.hashCode, isNot(equals(regWithPontosB.hashCode)));
      expect(reg1, isNot(equals(regWithPontosA)));
    });
  });
}
