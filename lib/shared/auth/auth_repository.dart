import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/local_user_model.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/models/user_model.dart';

import 'profile_store.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final ProfileStore _store;

  /// Apaga os dados locais do aluno (diário, estado do gatilho) ao sair.
  final Future<void> Function()? clearStudentData;

  AuthRepository(
    this._auth,
    this._firestore,
    this._store, {
    this.clearStudentData,
  });

  Future<SessionModel?> restoreSession() async {
    final user = _auth.currentUser;
    final profile = _store.read();

    if (user == null) {
      if (profile == null) return null;
      return StudentSessionModel(uid: await _studentUid(), user: profile);
    }

    if (user.isAnonymous) {
      if (profile == null) return null;
      return StudentSessionModel(uid: user.uid, user: profile);
    }

    try {
      final institutional = await _fetchUser(user.uid);
      if (institutional == null) throw const AccessDenied();
      return InstitutionalSession(institutional, email: user.email);
    } catch (error) {
      if (_isConnectivityError(error)) rethrow;
      await _auth.signOut();
      rethrow;
    }
  }

  bool _isConnectivityError(Object error) =>
      error is FirebaseException &&
      (error.code == 'unavailable' || error.code == 'deadline-exceeded');

  Future<StudentSessionModel> signInAsStudent(LocalUserModel profile) async {
    final user = _auth.currentUser;
    final uid = user != null && user.isAnonymous
        ? user.uid
        : await _studentUid();

    await _store.save(profile);
    return StudentSessionModel(uid: uid, user: profile);
  }

  /// Login anônimo do aluno. Sem internet, devolve o id local do aparelho
  /// para o aluno usar o diário offline (RNF02); o login anônimo é tentado
  /// de novo na próxima vez que o app abrir.
  Future<String> _studentUid() async {
    try {
      return (await _auth.signInAnonymously()).user!.uid;
    } on FirebaseAuthException catch (error) {
      if (error.code != 'network-request-failed') rethrow;
      return _store.localUid();
    }
  }

  Future<InstitutionalSession> signInAsInstitutional({
    required String email,
    required String password,
    required Role role,
  }) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      final user = await _fetchUser(credentials.user!.uid);
      if (user == null || user.role != role) throw AccessDenied();
      return InstitutionalSession(user, email: credentials.user!.email);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Sem usuário no Firebase, a sessão era a do aluno offline: o perfil
    // também precisa sair, senão o app entra de novo sozinho.
    if (_auth.currentUser?.isAnonymous ?? true) {
      await clearStudentData?.call();
      await _store.clear();
    }
    await _auth.signOut();
  }

  Future<UserModel?> _fetchUser(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .withConverter<UserModel>(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (_, _) => throw UnsupportedError('Apenas leitura'),
        )
        .get();
    return snapshot.data();
  }
}

class AccessDenied implements Exception {
  const AccessDenied();
}
