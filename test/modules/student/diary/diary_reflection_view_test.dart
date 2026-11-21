import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/diary_reflection_view.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_lock_repository.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  late LocalDiaryRepository repository;
  late LocalDiaryLockRepository lockRepository;

  setUp(() {
    repository = LocalDiaryRepository();
    lockRepository = LocalDiaryLockRepository();
  });

  Future<void> pumpView(WidgetTester tester,
      {Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: DiaryReflectionView(
          repository: repository,
          lockRepository: lockRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra cabeçalho, semana, botão e lista vazia (Figma)',
      (tester) async {
    await pumpView(tester);

    expect(find.text('Diário Pessoal'), findsOneWidget);
    expect(find.text('Anotar no Diário'), findsOneWidget);
    expect(find.text('Registros recentes'), findsOneWidget);
    expect(find.textContaining('Nenhum registro ainda'), findsOneWidget);
    expect(find.text('${DateTime.now().day}'), findsOneWidget);
  });

  testWidgets('anota texto, humor e pontos positivos e mostra na lista',
      (tester) async {
    await pumpView(tester);

    await tester.tap(find.byKey(const Key('botao_anotar_diario')));
    await tester.pumpAndSettle();
    expect(find.text('Pontos Positivos do Dia'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('campo_texto_reflexivo')),
      'Tirei nota boa na prova',
    );
    // Os chips ficam numa área rolável: rola até o chip antes de tocar.
    await tester.ensureVisible(find.byKey(const Key('ponto_Dormi bem')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ponto_Dormi bem')));
    await tester.pump();

    // Ponto escrito pelo aluno
    await tester.tap(find.byKey(const Key('botao_adicionar_ponto')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campo_novo_ponto')), 'Joguei bola');
    await tester.tap(find.byKey(const Key('confirmar_novo_ponto')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Joguei bola'));
    expect(find.text('Joguei bola'), findsOneWidget);

    // Sem humor, "Registrar" pede o humor e, escolhido, já salva.
    await tester.tap(find.byKey(const Key('botao_registrar')));
    await tester.pumpAndSettle();
    // A folha de humor mostra o Breno com a cara de cada emoção.
    for (final humor in Humor.values) {
      final breno = tester.widget<SvgPicture>(find.descendant(
        of: find.byKey(Key('humor_${humor.name}')),
        matching: find.byType(SvgPicture),
      ));
      expect((breno.bytesLoader as SvgAssetLoader).assetName, humor.brenoAsset);
    }
    await tester.tap(find.byKey(const Key('humor_feliz')));
    await tester.pumpAndSettle();

    final saved = (await repository.getAll()).single;
    expect(saved.humor, Humor.feliz);
    expect(saved.texto, 'Tirei nota boa na prova');
    expect(saved.pontosPositivos, ['Dormi bem', 'Joguei bola']);

    expect(find.text('Registro salvo no seu diário.'), findsOneWidget);
    expect(find.text('Tirei nota boa na prova'), findsOneWidget);
  });

  testWidgets('tocar num registro reabre o texto salvo', (tester) async {
    await repository.save(RegistroDiario(
      id: '1',
      humor: Humor.neutro,
      texto: 'Meu dia',
      pontosPositivos: const ['Ajudei um amigo'],
      dataHora: DateTime.now(),
    ));
    await pumpView(tester);

    await tester.tap(find.text('Meu dia'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
        find.byKey(const Key('campo_texto_reflexivo')));
    expect(field.controller!.text, 'Meu dia');
  });

  testWidgets('arrastar para a esquerda exclui o registro', (tester) async {
    await repository.save(RegistroDiario(
      id: '1',
      humor: Humor.triste,
      texto: 'Apagar isto',
      dataHora: DateTime.now(),
    ));
    await pumpView(tester);

    await tester.drag(find.text('Apagar isto'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Apagar isto'), findsNothing);
    expect(await repository.getAll(), isEmpty);
    expect(find.text('Desfazer'), findsOneWidget);
  });

  testWidgets('não estoura o layout em tela estreita (320x640)',
      (tester) async {
    await pumpView(tester, size: const Size(320, 640));
    await tester.tap(find.byKey(const Key('botao_anotar_diario')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar num dia anterior mostra os registros daquele dia',
      (tester) async {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day, 12);
    final ontem = DateTime(agora.year, agora.month, agora.day - 1, 12);
    await repository.save(RegistroDiario(
      id: 'ontem',
      humor: Humor.triste,
      texto: 'Registro de ontem',
      dataHora: ontem,
    ));
    await repository.save(RegistroDiario(
      id: 'hoje',
      humor: Humor.feliz,
      texto: 'Registro de hoje',
      dataHora: hoje,
    ));
    await pumpView(tester);

    expect(find.text('Registro de ontem'), findsOneWidget);
    expect(find.text('Registro de hoje'), findsOneWidget);

    // Se hoje é domingo, ontem fica na semana anterior.
    if (hoje.weekday == DateTime.sunday) {
      await tester.tap(find.byKey(const Key('semana_anterior')));
      await tester.pumpAndSettle();
    }
    final mm = ontem.month.toString().padLeft(2, '0');
    final dd = ontem.day.toString().padLeft(2, '0');
    await tester.tap(find.byKey(Key('dia_${ontem.year}-$mm-$dd')));
    await tester.pumpAndSettle();

    expect(find.text('Registros de $dd/$mm'), findsOneWidget);
    expect(find.text('Registro de ontem'), findsOneWidget);
    expect(find.text('Registro de hoje'), findsNothing);

    await tester.tap(find.byKey(const Key('ver_todos')));
    await tester.pumpAndSettle();
    expect(find.text('Registros recentes'), findsOneWidget);
    expect(find.text('Registro de hoje'), findsOneWidget);
  });

  testWidgets('setas trocam a semana e não passam da atual', (tester) async {
    await pumpView(tester);

    final proxima = find.byKey(const Key('proxima_semana'));
    expect(tester.widget<IconButton>(proxima).onPressed, isNull);

    final antes = tester
        .widget<Text>(find.byKey(const Key('semana_intervalo')))
        .data;
    await tester.tap(find.byKey(const Key('semana_anterior')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('semana_intervalo'))).data,
      isNot(antes),
    );
    expect(tester.widget<IconButton>(proxima).onPressed, isNotNull);
  });

  group('proteção por PIN (cadeado)', () {
    final cadeado = find.byKey(const Key('diario_cadeado'));
    final anotar = find.byKey(const Key('botao_anotar_diario'));

    // Abre o cadeado, escolhe a opção e preenche os campos do diálogo.
    Future<void> usarCadeado(
      WidgetTester tester,
      String opcao,
      Map<String, String> campos,
    ) async {
      await tester.tap(cadeado);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('pin_$opcao')));
      await tester.pumpAndSettle();
      for (final campo in campos.entries) {
        await tester.enterText(find.byKey(Key(campo.key)), campo.value);
      }
      await tester.tap(find.byKey(const Key('confirmar_pin')));
      await tester.pumpAndSettle();
    }

    testWidgets('sem PIN o diário abre direto', (tester) async {
      await pumpView(tester);

      expect(anotar, findsOneWidget);
      expect(find.byKey(const Key('campo_pin_desbloqueio')), findsNothing);
      expect(find.byTooltip('Proteger diário com PIN'), findsOneWidget);
    });

    testWidgets('cria PIN pelo cadeado e a tela passa a pedir o PIN',
        (tester) async {
      await pumpView(tester);

      await tester.tap(cadeado);
      await tester.pumpAndSettle();
      expect(find.text('Proteger o diário'), findsOneWidget);
      expect(find.byKey(const Key('pin_alterar')), findsNothing);
      expect(find.byKey(const Key('pin_remover')), findsNothing);
      await tester.tap(find.byKey(const Key('pin_criar')));
      await tester.pumpAndSettle();

      // Confirmação diferente não salva.
      await tester.enterText(
          find.byKey(const Key('campo_pin_novo')), '1234');
      await tester.enterText(
          find.byKey(const Key('campo_pin_confirmacao')), '4321');
      await tester.tap(find.byKey(const Key('confirmar_pin')));
      await tester.pumpAndSettle();
      expect(find.text('Os PINs não são iguais.'), findsOneWidget);
      expect(await lockRepository.hasPin(), isFalse);

      await tester.enterText(
          find.byKey(const Key('campo_pin_confirmacao')), '1234');
      await tester.tap(find.byKey(const Key('confirmar_pin')));
      await tester.pumpAndSettle();

      expect(await lockRepository.verify('1234'), isTrue);
      expect(find.textContaining('PIN criado'), findsOneWidget);
      expect(find.byTooltip('Diário protegido com PIN'), findsOneWidget);
      // Quem criou o PIN continua com o diário aberto.
      expect(anotar, findsOneWidget);

      // Ao abrir a tela de novo, o PIN é pedido.
      await tester.pumpWidget(const SizedBox());
      await pumpView(tester);
      expect(find.byKey(const Key('campo_pin_desbloqueio')), findsOneWidget);
      expect(anotar, findsNothing);
    });

    testWidgets('com PIN: errado mostra erro, certo abre o diário',
        (tester) async {
      await lockRepository.setPin('1234');
      repository = LocalDiaryRepository({
        '1': RegistroDiario(
          id: '1',
          humor: Humor.feliz,
          texto: 'Segredo do dia',
          dataHora: DateTime.now(),
        ),
      });
      await pumpView(tester);

      expect(find.text('Diário protegido'), findsOneWidget);
      expect(find.text('Segredo do dia'), findsNothing);
      expect(anotar, findsNothing);
      expect(tester.widget<IconButton>(cadeado).onPressed, isNull);

      await tester.enterText(
          find.byKey(const Key('campo_pin_desbloqueio')), '0000');
      await tester.tap(find.byKey(const Key('botao_desbloquear')));
      await tester.pumpAndSettle();
      expect(find.text('PIN incorreto. Tente de novo.'), findsOneWidget);
      expect(anotar, findsNothing);

      await tester.enterText(
          find.byKey(const Key('campo_pin_desbloqueio')), '1234');
      await tester.tap(find.byKey(const Key('botao_desbloquear')));
      await tester.pumpAndSettle();
      expect(anotar, findsOneWidget);
      expect(find.text('Segredo do dia'), findsOneWidget);
    });

    testWidgets('altera o PIN pelo cadeado exigindo o atual', (tester) async {
      await lockRepository.setPin('1234');
      await pumpView(tester);
      await tester.enterText(
          find.byKey(const Key('campo_pin_desbloqueio')), '1234');
      await tester.tap(find.byKey(const Key('botao_desbloquear')));
      await tester.pumpAndSettle();

      await usarCadeado(tester, 'alterar', {
        'campo_pin_atual': '9999',
        'campo_pin_novo': '5678',
        'campo_pin_confirmacao': '5678',
      });
      expect(find.text('PIN incorreto. Tente de novo.'), findsOneWidget);
      expect(await lockRepository.verify('1234'), isTrue);

      await tester.enterText(find.byKey(const Key('campo_pin_atual')), '1234');
      await tester.tap(find.byKey(const Key('confirmar_pin')));
      await tester.pumpAndSettle();

      expect(find.text('PIN alterado.'), findsOneWidget);
      expect(await lockRepository.verify('5678'), isTrue);
    });

    testWidgets('remove o PIN pelo cadeado', (tester) async {
      await lockRepository.setPin('1234');
      await pumpView(tester);
      await tester.enterText(
          find.byKey(const Key('campo_pin_desbloqueio')), '1234');
      await tester.tap(find.byKey(const Key('botao_desbloquear')));
      await tester.pumpAndSettle();

      await usarCadeado(tester, 'remover', {'campo_pin_atual': '1234'});

      expect(find.text('Proteção por PIN removida.'), findsOneWidget);
      expect(await lockRepository.hasPin(), isFalse);
      expect(find.byTooltip('Proteger diário com PIN'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await pumpView(tester);
      expect(anotar, findsOneWidget);
    });

    testWidgets('campo de PIN aceita só números', (tester) async {
      await lockRepository.setPin('1234');
      await pumpView(tester);

      await tester.enterText(
          find.byKey(const Key('campo_pin_desbloqueio')), '12ab');
      final campo = tester.widget<TextField>(find.descendant(
        of: find.byKey(const Key('campo_pin_desbloqueio')),
        matching: find.byType(TextField),
      ));
      expect(campo.controller!.text, '12');
      expect(campo.obscureText, isTrue);
    });
  });
}
