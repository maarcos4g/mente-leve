import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_overlay.dart';

void main() {
  testWidgets('Botão CVV persiste ao navegar entre telas e dispara a ação', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            CvvOverlay(onCvvPressed: () => pressed++, child: child!),
        routes: {
          '/': (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/b'),
              child: const Text('ir'),
            ),
          ),
          '/b': (context) => const Scaffold(body: Text('Tela B')),
        },
      ),
    );

    expect(find.text('Ajuda (CVV)'), findsOneWidget);

    await tester.tap(find.text('ir'));
    await tester.pumpAndSettle();

    expect(find.text('Tela B'), findsOneWidget);
    expect(find.text('Ajuda (CVV)'), findsOneWidget);

    await tester.tap(find.text('Ajuda (CVV)'));
    expect(pressed, 1);
  });

  test('CVV disca 188 pelo esquema tel', () {
    expect(CvvButton.cvvUri.toString(), 'tel:188');
  });
}
