import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_firestore.dart';

/// Bateria offline (EPIC-09): FAQ sem internet e na reconexão.
void main() {
  late FakeFirestore firestore;
  late SharedPreferences prefs;

  // Tempos curtos para os testes; no app são 2 s (escrita) e 6 s (leitura).
  FirestoreFaqRepository openRepository() => FirestoreFaqRepository(
    firestore,
    storage: prefs,
    writeWait: const Duration(milliseconds: 50),
    readWait: const Duration(milliseconds: 50),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    firestore = FakeFirestore();
  });

  group('sem internet', () {
    setUp(() => firestore.online = false);

    test('depois de salvar offline, a lista volta sem esperar a leitura '
        'longa', () async {
      // Como no emulador: a escrita fica sem resposta e a leitura também.
      firestore.hangReads = true;
      final repo = FirestoreFaqRepository(
        firestore,
        storage: prefs,
        writeWait: const Duration(milliseconds: 50),
        readWait: const Duration(seconds: 30),
        offlineReadWait: const Duration(milliseconds: 50),
      );

      final relogio = Stopwatch()..start();
      final criada = await repo.create(
        question: 'Rápida',
        answer: 'Resposta',
        updatedBy: 'psi',
      );
      final lista = await repo.list();

      expect(relogio.elapsed, lessThan(const Duration(seconds: 1)));
      expect(lista.first.id, criada.id);
    });

    test('criar pergunta termina sem travar e já aparece na lista', () async {
      final repo = openRepository();

      final criada = await repo
          .create(
            question: 'Pergunta offline',
            answer: 'Resposta',
            updatedBy: 'psi',
          )
          .timeout(const Duration(seconds: 1));

      expect(firestore.pending, hasLength(1));
      expect(firestore.server, isEmpty);
      expect((await repo.list()).first.id, criada.id);
    });

    test('editar e excluir também não travam', () async {
      firestore.online = true;
      final repo = openRepository();
      final item = await repo.create(
        question: 'Original',
        answer: 'Resposta',
        updatedBy: 'psi',
      );
      firestore.online = false;

      final editado = await repo
          .update(item.copyWith(question: 'Editada offline'))
          .timeout(const Duration(seconds: 1));
      expect(editado.question, 'Editada offline');
      expect((await repo.list()).first.question, 'Editada offline');

      await repo.delete(item.id).timeout(const Duration(seconds: 1));
      expect((await repo.list()).where((e) => e.id == item.id), isEmpty);
      expect(firestore.pending, hasLength(2));
    });

    test('sem cache, a leitura usa as perguntas padrão', () async {
      final lista = await openRepository().list();

      expect(lista.map((e) => e.id), defaultFaqItems.map((e) => e.id));
    });

    test('com cache, a leitura mostra o que veio da última conexão', () async {
      firestore
        ..online = true
        ..server['faq-servidor'] = {
          'question': 'Do servidor',
          'answer': 'Resposta',
          'updatedBy': 'psi',
        };
      await openRepository().list();
      firestore.online = false;

      final lista = await openRepository().list();

      expect(lista.single.question, 'Do servidor');
    });

    test('rede instável que não responde não trava a leitura', () async {
      firestore.hangReads = true;

      final lista = await openRepository().list().timeout(
        const Duration(seconds: 1),
      );

      expect(lista, isNotEmpty);
    });
  });

  group('reconexão', () {
    test('a pergunta criada offline sobe para o servidor', () async {
      firestore.online = false;
      final repo = openRepository();
      final criada = await repo.create(
        question: 'Criada no modo avião',
        answer: 'Resposta',
        updatedBy: 'psi',
      );

      firestore.reconnect();

      expect(firestore.pending, isEmpty);
      expect(firestore.server[criada.id]?['question'], 'Criada no modo avião');
    });

    test(
      'depois de reconectar, a lista vem do servidor sem duplicar',
      () async {
        firestore.online = false;
        final repo = openRepository();
        final criada = await repo.create(
          question: 'Criada no modo avião',
          answer: 'Resposta',
          updatedBy: 'psi',
        );
        firestore.reconnect();

        final lista = await repo.list();

        expect(lista.where((e) => e.id == criada.id), hasLength(1));
        expect(lista, hasLength(1));
      },
    );

    test('edição e exclusão offline chegam ao servidor na ordem', () async {
      final repo = openRepository();
      final mantida = await repo.create(
        question: 'Mantida',
        answer: 'Resposta',
        updatedBy: 'psi',
      );
      final apagada = await repo.create(
        question: 'Apagada',
        answer: 'Resposta',
        updatedBy: 'psi',
      );
      firestore.online = false;

      await repo.update(mantida.copyWith(question: 'Mantida e editada'));
      await repo.delete(apagada.id);
      firestore.reconnect();

      expect(firestore.server.keys, [mantida.id]);
      expect(firestore.server[mantida.id]?['question'], 'Mantida e editada');
    });
  });
}
