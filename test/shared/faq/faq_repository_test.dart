import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/faq_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FaqModel & English Firestore Schema Tests', () {
    final baseItem = FaqModel(
      id: 'faq-1',
      question: 'Como lidar com a ansiedade?',
      answer: 'Respire fundo e converse com alguém de confiança.',
      createdAt: DateTime.utc(2026, 11, 10, 12, 0),
      updatedAt: DateTime.utc(2026, 11, 10, 12, 30),
      updatedBy: 'uid-psychologist',
    );

    test('matches filtra por pergunta e resposta ignorando maiúsculas', () {
      expect(baseItem.matches(''), isTrue);
      expect(baseItem.matches('   '), isTrue);
      expect(baseItem.matches('ANSIEDADE'), isTrue);
      expect(baseItem.matches('confiança'), isTrue);
      expect(baseItem.matches('inexistente'), isFalse);
    });

    test('toFirestore e toMap utilizam chaves em inglês (padrão users)', () {
      final firestoreMap = baseItem.toFirestore();
      expect(
        firestoreMap.keys,
        containsAll(['question', 'answer', 'createdAt', 'updatedAt', 'updatedBy']),
      );
      expect(firestoreMap['question'], baseItem.question);
      expect(firestoreMap['answer'], baseItem.answer);
      expect(firestoreMap['updatedBy'], baseItem.updatedBy);

      final localMap = baseItem.toMap();
      expect(
        localMap.keys,
        containsAll(['id', 'question', 'answer', 'createdAt', 'updatedAt', 'updatedBy']),
      );

      final restored = FaqModel.fromMap(localMap);
      expect(restored, equals(baseItem));
      expect(restored.hashCode, equals(baseItem.hashCode));

      final edited = baseItem.copyWith(question: 'Nova pergunta?');
      expect(edited.question, 'Nova pergunta?');
      expect(edited.answer, baseItem.answer);
      expect(edited, isNot(equals(baseItem)));
    });

    test('UserModel suporta photoUrl para foto da psicóloga no Firestore', () {
      final user = UserModel(
        uid: 'uid-1',
        name: 'Dra. Mariana',
        role: Role.psychologist,
        createdAt: DateTime.utc(2026, 11, 1),
        photoUrl: 'https://example.com/mariana.jpg',
      );
      expect(user.name, 'Dra. Mariana');
      expect(user.photoUrl, 'https://example.com/mariana.jpg');
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

      final items = await repo.list();
      expect(items.length, defaultFaqItems.length);
      expect(items.first.question, 'O que é cyberbullying');
    });

    test('CRUD completo persiste no SharedPreferences para acesso offline', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalFaqRepository(storage: prefs);

      // Create
      final created = await repo.create(
        question: 'O que fazer ao presenciar bullying?',
        answer: 'Apoie o colega e relate de forma anônima no aplicativo.',
        updatedBy: 'psychologist-1',
      );
      expect(created.question, 'O que fazer ao presenciar bullying?');

      // Nova instância lendo do mesmo SharedPreferences (simulando reabertura offline)
      final repoOffline = LocalFaqRepository(storage: prefs);
      final afterCreate = await repoOffline.list();
      expect(afterCreate.length, defaultFaqItems.length + 1);
      expect(afterCreate.first.id, created.id);

      // Update
      final updated = await repo.update(
        created.copyWith(answer: 'Resposta atualizada pela psicóloga.'),
      );
      expect(updated.answer, 'Resposta atualizada pela psicóloga.');

      final afterUpdate = await repoOffline.list();
      expect(
        afterUpdate.firstWhere((e) => e.id == created.id).answer,
        'Resposta atualizada pela psicóloga.',
      );

      // Delete
      await repo.delete(created.id);
      final afterDelete = await repoOffline.list();
      expect(afterDelete.any((e) => e.id == created.id), isFalse);
      expect(afterDelete.length, defaultFaqItems.length);
    });
  });
}
