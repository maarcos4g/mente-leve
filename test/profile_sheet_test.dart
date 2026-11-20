import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/auth/auth_repository.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/local_user_model.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';
import 'package:mente_leve/shared/widgets/profile/profile_sheet.dart';
import 'package:provider/provider.dart';

class _FakeRepository extends Fake implements AuthRepository {
  _FakeRepository(this.session);

  final SessionModel session;
  int signOutCalls = 0;

  @override
  Future<SessionModel?> restoreSession() async => session;

  @override
  Future<void> signOut() async => signOutCalls++;
}

final _student = StudentSessionModel(
  uid: 'anon',
  user: LocalUserModel(nickname: 'Panda', avatar: 'panda.svg'),
);

final _psychologist = InstitutionalSession(
  UserModel(
    uid: 'psi',
    name: 'Dra. Ana',
    role: Role.psychologist,
    createdAt: DateTime(2026),
  ),
  email: 'ana@escola.edu.br',
);

Future<_FakeRepository> _pump(WidgetTester tester, SessionModel session) async {
  final repository = _FakeRepository(session);
  final auth = AuthNotifier(repository);
  await auth.restore();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(
        routes: {
          '/onboarding': (_) => const Scaffold(body: Text('Onboarding')),
        },
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showProfileSheet(context),
              child: const Text('Perfil'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Perfil'));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('aluno vê só codinome e perfil anônimo', (tester) async {
    await _pump(tester, _student);

    expect(find.text('Panda'), findsOneWidget);
    expect(find.text('Perfil anônimo'), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets('psicóloga vê nome, e-mail e papel', (tester) async {
    await _pump(tester, _psychologist);

    expect(find.text('Dra. Ana'), findsOneWidget);
    expect(find.text('ana@escola.edu.br'), findsOneWidget);
    expect(find.text('Psicóloga'), findsOneWidget);
  });

  testWidgets('aluno: diálogo avisa da remoção e cancelar não sai', (
    tester,
  ) async {
    final repository = await _pump(tester, _student);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('será removido deste aparelho'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 0);
    expect(find.text('Onboarding'), findsNothing);
  });

  testWidgets('institucional: confirmar sai e vai para /onboarding', (
    tester,
  ) async {
    final repository = await _pump(tester, _psychologist);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('removido'), findsNothing);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(find.text('Onboarding'), findsOneWidget);
  });
}
