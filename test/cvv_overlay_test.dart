import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_overlay.dart';

Widget _app(CvvRouteObserver observer, VoidCallback onPressed) {
  return MaterialApp(
    navigatorObservers: [observer],
    builder: (context, child) =>
        CvvOverlay(observer: observer, onCvvPressed: onPressed, child: child!),
    routes: {
      '/': (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.pushNamed(context, '/auth/student'),
          child: const Text('ir login'),
        ),
      ),
      '/auth/student': (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (_) => false,
          ),
          child: const Text('entrar'),
        ),
      ),
      '/home': (context) => const Scaffold(body: Text('Home')),
    },
  );
}

void main() {
  testWidgets('Botão CVV aparece fora do login, some no login e volta na home', (
    tester,
  ) async {
    var pressed = 0;
    final observer = CvvRouteObserver();
    await tester.pumpWidget(_app(observer, () => pressed++));
    await tester.pumpAndSettle();

    expect(find.text('Ajuda (CVV)'), findsOneWidget);
    await tester.tap(find.text('Ajuda (CVV)'));
    expect(pressed, 1);

    await tester.tap(find.text('ir login'));
    await tester.pumpAndSettle();
    expect(find.text('Ajuda (CVV)'), findsNothing);

    await tester.tap(find.text('entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Ajuda (CVV)'), findsOneWidget);
  });

  test('CVV disca 188 pelo esquema tel', () {
    expect(CvvButton.cvvUri.toString(), 'tel:188');
  });
}
