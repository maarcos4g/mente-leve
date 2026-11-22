import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';

/// Bateria offline (EPIC-09): o botão CVV só abre o discador do aparelho
/// (`tel:188`), sem usar a internet. Se o discador não abrir, o aluno vê um
/// aviso e a tela continua respondendo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> pumpCvv(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: Center(child: CvvButton())),
    ),
  );

  testWidgets('abre o discador com o 188, sem depender de rede', (
    tester,
  ) async {
    final chamadas = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      chamadas.add((call.arguments as Map)['url'] as String);
      return true;
    });

    await pumpCvv(tester);
    await tester.tap(find.text('Ajuda (CVV)'));
    await tester.pumpAndSettle();

    expect(chamadas, ['tel:188']);
    expect(find.text('Não foi possível abrir o discador.'), findsNothing);
  });

  testWidgets('sem discador, avisa e a tela não trava', (tester) async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
    );

    await pumpCvv(tester);
    await tester.tap(find.text('Ajuda (CVV)'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível abrir o discador.'), findsOneWidget);

    // A tela segue respondendo: um segundo toque mostra o aviso de novo.
    await tester.tap(find.text('Ajuda (CVV)'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  test('dial() nunca lança erro, mesmo sem discador', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (call) async => throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
    );

    expect(await CvvButton.dial(), isFalse);
  });
}
