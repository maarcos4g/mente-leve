import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/auth/auth_repository.dart';
import 'package:mente_leve/shared/auth/profile_store.dart';
import 'package:mente_leve/shared/models/local_user_model.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Usuário do Firebase só com o que o `AuthRepository` lê.
class _FakeUser implements User {
  _FakeUser(this.uid, {this.isAnonymous = true});

  @override
  final String uid;

  @override
  final bool isAnonymous;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCredential implements UserCredential {
  _FakeCredential(this.user);

  @override
  final User? user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `FirebaseAuth` que simula estar com ou sem internet.
class _FakeAuth implements FirebaseAuth {
  bool online = true;
  String? errorCode;
  int anonymousSignIns = 0;
  int signOuts = 0;

  @override
  User? currentUser;

  @override
  Future<UserCredential> signInAnonymously() async {
    anonymousSignIns++;
    if (!online) {
      throw FirebaseAuthException(code: 'network-request-failed');
    }
    if (errorCode != null) throw FirebaseAuthException(code: errorCode!);
    currentUser = _FakeUser('firebase-uid');
    return _FakeCredential(currentUser);
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    currentUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// O fluxo do aluno nunca toca no Firestore.
class _FakeFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeAuth auth;
  late ProfileStore store;
  late AuthRepository repository;

  final perfil = LocalUserModel(nickname: 'abraao', avatar: 'panda.svg');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = _FakeAuth();
    store = ProfileStore(await SharedPreferences.getInstance());
    repository = AuthRepository(auth, _FakeFirestore(), store);
  });

  group('aluno sem internet', () {
    setUp(() => auth.online = false);

    test('o primeiro acesso entra com sessão local e salva o perfil', () async {
      final session = await repository.signInAsStudent(perfil);

      expect(session.uid, startsWith('local-'));
      expect(session.user.nickname, 'abraao');
      expect(store.read()?.nickname, 'abraao');
    });

    test('o id local é o mesmo em toda entrada offline', () async {
      final primeira = await repository.signInAsStudent(perfil);
      final reaberto = await repository.restoreSession();

      expect(reaberto, isA<StudentSessionModel>());
      expect(reaberto!.uid, primeira.uid);
    });

    test('sem perfil salvo, reabrir o app vai para o onboarding', () async {
      expect(await repository.restoreSession(), isNull);
      expect(auth.anonymousSignIns, 0);
    });

    test('sair apaga o perfil e o id local', () async {
      final antes = await repository.signInAsStudent(perfil);
      await repository.signOut();

      expect(store.read(), isNull);
      expect(await repository.restoreSession(), isNull);

      final depois = await repository.signInAsStudent(perfil);
      expect(depois.uid, isNot(antes.uid));
    });
  });

  group('aluno com internet', () {
    test('entra com o login anônimo do Firebase', () async {
      final session = await repository.signInAsStudent(perfil);

      expect(session.uid, 'firebase-uid');
      expect(auth.anonymousSignIns, 1);
    });

    test('quem entrou offline ganha o login anônimo quando a rede volta',
        () async {
      auth.online = false;
      await repository.signInAsStudent(perfil);

      auth.online = true;
      final session = await repository.restoreSession();

      expect(session!.uid, 'firebase-uid');
      expect(store.read()?.nickname, 'abraao');
    });

    test('reaproveita o anônimo que já está logado', () async {
      auth.currentUser = _FakeUser('anonimo-antigo');

      final session = await repository.signInAsStudent(perfil);

      expect(session.uid, 'anonimo-antigo');
      expect(auth.anonymousSignIns, 0);
    });

    test('usuário institucional ao sair não apaga o perfil do aluno', () async {
      await store.save(perfil);
      auth.currentUser = _FakeUser('psicologa', isAnonymous: false);

      await repository.signOut();

      expect(store.read()?.nickname, 'abraao');
      expect(auth.signOuts, 1);
    });

    test('erro que não é de rede continua subindo', () async {
      auth.errorCode = 'operation-not-allowed';

      await expectLater(
        repository.signInAsStudent(perfil),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(store.read(), isNull);
    });
  });
}
