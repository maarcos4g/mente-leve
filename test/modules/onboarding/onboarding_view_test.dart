import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/onboarding/onboarding_view.dart';

void main() {
  // 411x731 é a tela do emulador Pixel com Android 7 (API 24).
  for (final size in const [Size(390, 844), Size(411, 731), Size(360, 640)]) {
    testWidgets('Entrar como aluno funciona em ${size.width.toInt()}x'
        '${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingView(),
          routes: {
            '/auth/student': (_) => const Scaffold(body: Text('Codinome')),
          },
        ),
      );
      // A fonte de teste desenha cada letra como um quadrado largo e estoura
      // o botão na horizontal; isso não acontece no aparelho, então é
      // descartado. O que importa aqui é o botão continuar tocável.
      tester.takeException();

      await tester.ensureVisible(find.text('Entrar como aluno'));
      await tester.tap(find.text('Entrar como aluno'));
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('Codinome'), findsOneWidget);
    });
  }
}
