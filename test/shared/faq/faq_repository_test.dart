import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/pergunta_faq.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PerguntaFaq Model Tests', () {
    final baseItem = PerguntaFaq(
      id: 'faq-1',
      pergunta: 'Como lidar com a ansiedade?',
      resposta: 'Respire fundo e converse com alguém de confiança.',
      criadoEm: DateTime.utc(2026, 11, 10, 12, 0),
      atualizadoEm: DateTime.utc(2026, 11, 10, 12, 30),
      atualizadoPor: 'uid-psicologa',
    );

    test('corresponde filtra por pergunta e resposta ignorando maiúsculas', () {
      expect(baseItem.corresponde(''), isTrue);
      expect(baseItem.corresponde('   '), isTrue);
      expect(baseItem.corresponde('ANSIEDADE'), isTrue);
      expect(baseItem.corresponde('confiança'), isTrue);
      expect(baseItem.corresponde('inexistente'), isFalse);
    });

    test('toMap, fromMap, copyWith e igualdade preservam todos os campos', () {
      final map = baseItem.toMap();
      final restored = PerguntaFaq.fromMap(map);
      expect(restored, equals(baseItem));
      expect(restored.hashCode, equals(baseItem.hashCode));

      final edited = baseItem.copyWith(pergunta: 'Nova pergunta?');
      expect(edited.pergunta, 'Nova pergunta?');
      expect(edited.resposta, baseItem.resposta);
      expect(edited, isNot(equals(baseItem)));
    });
  });

  group('LocalFaqRepository & Cache Offline Tests (SCRUM-33 / SCRUM-36)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      LocalFaqRepository.instance.resetToDefaults();
    });

    test('inicia com defaultFaqItems do protótipo quando não há cache', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalFaqRepository(storage: prefs);

      final items = await repo.listar();
      expect(items.length, defaultFaqItems.length);
      expect(items.first.pergunta, 'O que é cyberbullying');
    });

    test('CRUD completo persiste no SharedPreferences para acesso offline', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalFaqRepository(storage: prefs);

      // Create
      final criado = await repo.criar(
        pergunta: 'O que fazer ao presenciar bullying?',
        resposta: 'Apoie o colega e relate de forma anônima no aplicativo.',
        atualizadoPor: 'psicologa-1',
      );
      expect(criado.pergunta, 'O que fazer ao presenciar bullying?');

      // Nova instância lendo do mesmo SharedPreferences (simulando reabertura offline)
      final repoOffline = LocalFaqRepository(storage: prefs);
      final aposCriar = await repoOffline.listar();
      expect(aposCriar.length, defaultFaqItems.length + 1);
      expect(aposCriar.first.id, criado.id);

      // Update
      final atualizado = await repo.atualizar(
        criado.copyWith(resposta: 'Resposta atualizada pela psicóloga.'),
      );
      expect(atualizado.resposta, 'Resposta atualizada pela psicóloga.');

      final aposAtualizar = await repoOffline.listar();
      expect(
        aposAtualizar.firstWhere((e) => e.id == criado.id).resposta,
        'Resposta atualizada pela psicóloga.',
      );

      // Delete
      await repo.excluir(criado.id);
      final aposExcluir = await repoOffline.listar();
      expect(aposExcluir.any((e) => e.id == criado.id), isFalse);
      expect(aposExcluir.length, defaultFaqItems.length);
    });
  });
}
