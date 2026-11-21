import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/psychologist/faq/psychologist_faq_controller.dart';
import 'package:mente_leve/shared/faq/faq_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_firestore.dart';

/// Bateria offline (EPIC-09): painel de FAQ da psicóloga no modo avião.
void main() {
  late FakeFirestore firestore;
  late PsychologistFaqController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    firestore = FakeFirestore()..online = false;
    controller = PsychologistFaqController(
      repository: FirestoreFaqRepository(
        firestore,
        storage: await SharedPreferences.getInstance(),
        writeWait: const Duration(milliseconds: 50),
        readWait: const Duration(milliseconds: 50),
      ),
    );
    await controller.carregar();
  });

  test('salvar sem internet não deixa a tela girando', () async {
    final salvou = await controller
        .salvar(question: 'Pergunta no modo avião', answer: 'Resposta')
        .timeout(const Duration(seconds: 1));

    expect(salvou, isTrue);
    expect(controller.isSaving, isFalse);
    expect(controller.errorMessage, isNull);
    expect(controller.items.first.question, 'Pergunta no modo avião');
  });

  test('a pergunta salva offline sobe quando a internet volta', () async {
    await controller.salvar(question: 'Pergunta no modo avião', answer: 'R');

    firestore.reconnect();
    await controller.carregar();

    expect(firestore.server.values.map((e) => e['question']), [
      'Pergunta no modo avião',
    ]);
    expect(controller.items.single.question, 'Pergunta no modo avião');
  });

  test('excluir sem internet também termina', () async {
    await controller.salvar(question: 'Vai sumir', answer: 'R');
    final id = controller.items.first.id;

    final excluiu = await controller
        .excluir(id)
        .timeout(const Duration(seconds: 1));

    expect(excluiu, isTrue);
    expect(controller.items.where((e) => e.id == id), isEmpty);
  });
}
