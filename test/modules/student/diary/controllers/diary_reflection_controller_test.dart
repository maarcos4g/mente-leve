import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/controllers/diary_reflection_controller.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  late LocalDiaryRepository repository;
  late DiaryReflectionController controller;

  setUp(() {
    repository = LocalDiaryRepository();
    controller = DiaryReflectionController(repository: repository);
  });

  tearDown(() => controller.dispose());

  RegistroDiario registro({
    String id = 'r1',
    Humor humor = Humor.neutro,
    String? texto,
    List<String> pontos = const [],
    DateTime? data,
  }) =>
      RegistroDiario(
        id: id,
        humor: humor,
        texto: texto,
        pontosPositivos: pontos,
        dataHora: data ?? DateTime.now(),
      );

  group('DiaryReflectionController (RF02)', () {
    test('abre registro novo com as sugestões e nada marcado', () async {
      await controller.load();
      controller.abrir();

      expect(controller.editando, isNull);
      expect(controller.pontos, DiaryReflectionController.sugestoes.keys);
      expect(controller.pontos.any(controller.isMarcado), isFalse);
      expect(controller.canSave, isFalse);
    });

    test('só permite salvar com humor e texto ou ponto marcado', () async {
      await controller.load();
      controller.abrir();

      controller.selectHumor(Humor.feliz);
      expect(controller.canSave, isFalse);

      controller.setTexto('   ');
      expect(controller.canSave, isFalse);

      controller.togglePonto('Dormi bem');
      expect(controller.canSave, isTrue);

      controller
        ..togglePonto('Dormi bem')
        ..setTexto('Hoje foi tranquilo');
      expect(controller.canSave, isTrue);
    });

    test('cria registro novo e atualiza a lista', () async {
      await controller.load();
      controller
        ..abrir()
        ..selectHumor(Humor.cansado)
        ..setTexto('  Dia longo na escola.  ')
        ..togglePonto('Ri de alguma coisa')
        ..togglePonto('Dormi bem');

      expect(await controller.save(), isTrue);

      final saved = controller.entries.single;
      expect(saved.humor, Humor.cansado);
      expect(saved.texto, 'Dia longo na escola.');
      // Ordem da tela, não a ordem dos toques.
      expect(saved.pontosPositivos, ['Dormi bem', 'Ri de alguma coisa']);
      expect(await repository.getAll(), [saved]);
    });

    test('"Anotar" completa o registro de hoje em vez de duplicar', () async {
      final hoje = registro(humor: Humor.triste);
      await repository.save(hoje);
      await controller.load();

      controller.abrir();
      expect(controller.editando, hoje);
      expect(controller.humor, Humor.triste);

      controller
        ..setTexto('Escrevi para desabafar')
        ..togglePonto('Me senti confiante');
      await controller.save();

      final saved = (await repository.getAll()).single;
      expect(saved.id, 'r1');
      expect(saved.dataHora, hoje.dataHora);
      expect(saved.texto, 'Escrevi para desabafar');
      expect(saved.pontosPositivos, ['Me senti confiante']);
    });

    test('registro de outro dia não é reaberto por "Anotar"', () async {
      await repository.save(registro(
        id: 'ontem',
        texto: 'Ontem',
        data: DateTime.now().subtract(const Duration(days: 1)),
      ));
      await controller.load();

      controller.abrir();

      expect(controller.editando, isNull);
      expect(controller.texto, isEmpty);
    });

    test('tocar num registro antigo abre esse registro para edição', () async {
      final antigo = registro(
        id: 'antigo',
        texto: 'Texto salvo',
        pontos: const ['Dormi bem', 'Joguei bola'],
        data: DateTime(2026, 11, 1),
      );
      await repository.save(antigo);
      await controller.load();

      controller.abrir(antigo);

      expect(controller.editando, antigo);
      expect(controller.texto, 'Texto salvo');
      expect(controller.pontos.last, 'Joguei bola');
      expect(controller.isMarcado('Dormi bem'), isTrue);
      expect(controller.isMarcado('Joguei bola'), isTrue);
      expect(controller.isMarcado('Ajudei um amigo'), isFalse);
    });

    test('apagar o texto de um registro remove o texto salvo', () async {
      await repository.save(
          registro(texto: 'Antigo', pontos: const ['Dormi bem']));
      await controller.load();
      controller
        ..abrir()
        ..setTexto('');

      await controller.save();

      expect((await repository.getLatest())!.texto, isNull);
    });

    test('adiciona ponto personalizado já marcado e recusa repetido ou vazio',
        () async {
      controller.abrir();

      expect(controller.addPonto('  Terminei um livro '), isTrue);
      expect(controller.pontos.last, 'Terminei um livro');
      expect(controller.isMarcado('Terminei um livro'), isTrue);

      expect(controller.addPonto('terminei um LIVRO'), isFalse);
      expect(controller.addPonto('dormi bem'), isFalse);
      expect(controller.addPonto('   '), isFalse);
      expect(
        controller
            .addPonto('a' * (DiaryReflectionController.maxPontoLength + 1)),
        isFalse,
      );
    });

    test('exclui e desfaz a exclusão', () async {
      final r = registro(texto: 'Para apagar');
      await repository.save(r);
      await controller.load();

      await controller.delete(r);
      expect(controller.entries, isEmpty);
      expect(await repository.getAll(), isEmpty);

      await controller.restore(r);
      expect(controller.entries, [r]);
    });

    test('marca na semana só os dias com registro', () async {
      await repository.save(registro());
      await controller.load();

      expect(controller.temRegistroEm(DateTime.now()), isTrue);
      expect(
        controller.temRegistroEm(
            DateTime.now().subtract(const Duration(days: 1))),
        isFalse,
      );
    });

    test('título do item: texto, depois pontos, depois humor', () {
      expect(
        DiaryReflectionController.tituloDe(
            registro(texto: 'Primeira linha\nSegunda')),
        'Primeira linha',
      );
      expect(
        DiaryReflectionController.tituloDe(
            registro(pontos: const ['Dormi bem', 'Ajudei um amigo'])),
        'Dormi bem e mais 1',
      );
      expect(
        DiaryReflectionController.tituloDe(registro(humor: Humor.feliz)),
        'Me senti feliz',
      );
    });

    test('retorna false quando o repositório falha', () async {
      final failing =
          DiaryReflectionController(repository: _FailingRepository());
      addTearDown(failing.dispose);
      failing
        ..abrir()
        ..selectHumor(Humor.feliz)
        ..setTexto('Teste');

      expect(await failing.save(), isFalse);
      expect(failing.isSaving, isFalse);
    });
  });
}

class _FailingRepository extends LocalDiaryRepository {
  @override
  Future<void> save(RegistroDiario registro) async =>
      throw Exception('disco cheio');
}
