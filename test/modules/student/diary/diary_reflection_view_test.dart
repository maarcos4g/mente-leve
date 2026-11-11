import 'package:flutter/material.dart';
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
}
