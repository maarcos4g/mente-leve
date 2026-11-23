import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/guides/guide_repository.dart';
import 'package:mente_leve/shared/models/guide_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GuideModel & English Firestore Schema Tests', () {
    test(
      'toFirestore e toMap utilizam chaves em inglês conforme modelagem',
      () {
        final now = DateTime.utc(2026, 11, 22, 12, 0);
        final item = GuideModel(
          id: 'guide-1',
          title: 'Sinais de ansiedade',
          description: 'Resumo para responsáveis.',
          text: 'Conteúdo completo da orientação.',
          category: 'Saúde Mental Juvenil',
          createdAt: now,
          updatedAt: now,
          authorUid: 'psi-01',
        );

        final firestore = item.toFirestore();
        expect(firestore.containsKey('title'), isTrue);
        expect(firestore.containsKey('description'), isTrue);
        expect(firestore.containsKey('text'), isTrue);
        expect(firestore.containsKey('category'), isTrue);
        expect(firestore.containsKey('createdAt'), isTrue);
        expect(firestore.containsKey('updatedAt'), isTrue);
        expect(firestore.containsKey('authorUid'), isTrue);
        expect(firestore.containsKey('titulo'), isFalse);

        final map = item.toMap();
        expect(map['title'], 'Sinais de ansiedade');
        expect(map['category'], 'Saúde Mental Juvenil');
        expect(GuideModel.fromMap(map), item);
      },
    );

    test('omite category no toFirestore quando nula ou vazia', () {
      final now = DateTime.utc(2026, 11, 22, 12, 0);
      final item = GuideModel(
        id: 'guide-2',
        title: 'Título',
        description: 'Descrição',
        text: 'Texto',
        category: '   ',
        createdAt: now,
        updatedAt: now,
      );

      expect(item.toFirestore().containsKey('category'), isFalse);
      expect(item.displayCategory, GuideModel.defaultCategory);
    });

    test('fromMap resiste a campos ausentes ou tipos inválidos sem erro', () {
      final parsed = GuideModel.fromMap({
        'id': 123,
        'title': null,
        'description': ['invalido'],
        'text': {'a': 1},
        'category': 99,
        'createdAt': 'data-invalida',
      });

      expect(parsed.id, '');
      expect(parsed.title, '');
      expect(parsed.description, '');
      expect(parsed.text, '');
      expect(parsed.category, isNull);
      expect(parsed.displayCategory, GuideModel.defaultCategory);
    });
  });

  group('LocalGuideRepository & Cache Offline Tests (RF08 / RF11)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('inicia com defaultGuideItems quando não há cache salvo', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalGuideRepository(storage: prefs);

      final items = await repo.list();
      expect(items.length, defaultGuideItems.length);
      expect(items.first.title, contains('ansiedade'));
    });

    test(
      'CRUD completo persiste no SharedPreferences para leitura offline',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final repo = LocalGuideRepository(storage: prefs);

        final created = await repo.create(
          title: 'Conversando sobre redes sociais',
          description: 'Dicas práticas para acompanhar o uso de telas.',
          text: 'Texto informativo completo sobre segurança digital.',
          category: 'Segurança Digital',
          authorUid: 'psi-uid-1',
        );

        expect(created.title, 'Conversando sobre redes sociais');
        expect(created.category, 'Segurança Digital');

        final reloadedRepo = LocalGuideRepository(storage: prefs);
        final afterCreate = await reloadedRepo.list();
        expect(afterCreate.any((g) => g.id == created.id), isTrue);

        final updated = await reloadedRepo.update(
          created.copyWith(title: 'Redes sociais com segurança'),
        );
        expect(updated.title, 'Redes sociais com segurança');

        final afterUpdate = await LocalGuideRepository(storage: prefs).list();
        expect(
          afterUpdate.firstWhere((g) => g.id == created.id).title,
          'Redes sociais com segurança',
        );

        await reloadedRepo.delete(created.id);
        final afterDelete = await LocalGuideRepository(storage: prefs).list();
        expect(afterDelete.any((g) => g.id == created.id), isFalse);
      },
    );
  });
}
