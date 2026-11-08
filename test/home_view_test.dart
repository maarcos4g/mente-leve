import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/modules/student/home/home_view.dart';

Future<void> _pumpHome(
  WidgetTester tester, {
  required Size size,
  Set<String> availableRoutes = const {},
  VoidCallback? onCvvPressed,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: HomeView(
        availableRoutes: availableRoutes,
        onCvvPressed: onCvvPressed,
      ),
    ),
  );
}

void main() {
  for (final size in const [Size(390, 844), Size(360, 640)]) {
    testWidgets('Home mostra todos os blocos em ${size.width.toInt()}x'
        '${size.height.toInt()}', (tester) async {
      await _pumpHome(tester, size: size);

      expect(find.text('Olá,'), findsOneWidget);
      expect(find.text('Panda!'), findsOneWidget);
      expect(find.text('Como está sua mente hoje?'), findsOneWidget);
      expect(find.text('Resumo da semana'), findsOneWidget);
      expect(find.text('Diário\nPessoal'), findsOneWidget);
      expect(find.text('Chat\nAnônimo'), findsOneWidget);
      expect(find.text('Canais de Apoio'), findsOneWidget);
      expect(find.text('& FAQ'), findsOneWidget);
      expect(find.text('Ajuda (CVV)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Toque em card sem rota registrada avisa que vem em breve', (
    tester,
  ) async {
    await _pumpHome(tester, size: const Size(390, 844));

    await tester.tap(find.text('Diário\nPessoal'));
    await tester.pump();

    expect(find.text('Disponível em breve.'), findsOneWidget);
  });

  testWidgets('Botão CVV dispara a ação', (tester) async {
    var pressed = 0;
    await _pumpHome(
      tester,
      size: const Size(390, 844),
      onCvvPressed: () => pressed++,
    );

    await tester.tap(find.text('Ajuda (CVV)'));

    expect(pressed, 1);
  });
}
