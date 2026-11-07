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

  AuthRepository(this._auth, this._firestore, this._store);

  Future<SessionModel?> restoreSession() async {
    final user = _auth.currentUser;
    final profile = _store.read();

    if (user == null) {
      if (profile == null) return null;

      final anonymous = (await _auth.signInAnonymously()).user!;
      return StudentSessionModel(uid: anonymous.uid, user: profile);
    }

    if (user.isAnonymous) {
      if (profile == null) return null;
      return StudentSessionModel(uid: user.uid, user: profile);
    }

    try {
      final institutional = await _fetchUser(user.uid);
      if (institutional == null) throw const AccessDenied();
      return InstitutionalSession(institutional);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<StudentSessionModel> signInAsStudent(LocalUserModel profile) async {
    var user = _auth.currentUser;

    if (user == null || !user.isAnonymous) {
      user = (await _auth.signInAnonymously()).user!;
    }
    await _store.save(profile);
    return StudentSessionModel(uid: user.uid, user: profile);
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
      return InstitutionalSession(user);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_auth.currentUser?.isAnonymous ?? false) await _store.clear();
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
