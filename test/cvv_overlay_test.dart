import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_overlay.dart';

Widget _app(CvvRouteObserver observer, VoidCallback onPressed) {
  Widget page(String label, String? next) => Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: next == null
            ? null
            : () => Navigator.pushNamedAndRemoveUntil(
                context,
                next,
                (_) => false,
              ),
        child: Text(label),
      ),
    ),
  );

  return MaterialApp(
    navigatorObservers: [observer],
    builder: (context, child) =>
        CvvOverlay(observer: observer, onCvvPressed: onPressed, child: child!),
    routes: {
      '/splash': (_) => page('splash', '/onboarding'),
      '/onboarding': (_) => page('onboarding', '/auth/student'),
      '/auth/student': (_) => page('login', '/student/home'),
      '/student/home': (_) => page('home aluno', '/parents/home'),
      '/parents/home': (_) => page('home pais', '/psychologist/home'),
      '/psychologist/home': (_) => page('home psicologo', null),
    },
    initialRoute: '/splash',
  );
}

void main() {
  testWidgets('CVV só aparece nas telas funcionais do aluno', (tester) async {
    var pressed = 0;
    final observer = CvvRouteObserver();
    await tester.pumpWidget(_app(observer, () => pressed++));
    await tester.pumpAndSettle();

    Future<void> goTo(String label) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    final cvv = find.text('Ajuda (CVV)');

    expect(find.text('splash'), findsOneWidget);
    expect(cvv, findsNothing);

    await goTo('splash');
    expect(find.text('onboarding'), findsOneWidget);
    expect(cvv, findsNothing);

    await goTo('onboarding');
    expect(find.text('login'), findsOneWidget);
    expect(cvv, findsNothing);

    await goTo('login');
    expect(find.text('home aluno'), findsOneWidget);
    expect(cvv, findsOneWidget);
    await tester.tap(cvv);
    expect(pressed, 1);

    await goTo('home aluno');
    expect(find.text('home pais'), findsOneWidget);
    expect(cvv, findsNothing);

    await goTo('home pais');
    expect(find.text('home psicologo'), findsOneWidget);
    expect(cvv, findsNothing);
  });

  test('CVV disca 188 pelo esquema tel', () {
    expect(CvvButton.cvvUri.toString(), 'tel:188');
  });
}
