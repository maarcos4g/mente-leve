import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/diary/diary_reflection_view.dart';
import 'package:mente_leve/modules/student/diary/models/humor_enum.dart';
import 'package:mente_leve/modules/student/diary/models/registro_diario.dart';
import 'package:mente_leve/modules/student/diary/repositories/diary_repository.dart';

void main() {
  late LocalDiaryRepository repository;

  setUp(() => repository = LocalDiaryRepository());

  Future<void> pumpView(WidgetTester tester,
      {Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: DiaryReflectionView(repository: repository)),
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
}
