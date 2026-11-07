import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mente_leve/shared/auth/auth_repository.dart';
import 'package:mente_leve/shared/models/local_user_model.dart';
import 'package:mente_leve/shared/models/session_model.dart';

import '../models/enums/user_role.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;

  AuthNotifier(this._repository);

  SessionModel? _session;
  SessionModel? get session => _session;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> restore() async {
    try {
      _session = await _repository.restoreSession();
    } catch (_) {
      _session = null;
    }
    notifyListeners();
  }

  Future<String?> signInAsStudent(LocalUserModel profile) =>
      _run(() => _repository.signInAsStudent(profile));

  Future<String?> signInAsInstitutional({
    required String email,
    required String password,
    required Role role,
  }) => _run(
    () => _repository.signInAsInstitutional(
      email: email,
      password: password,
      role: role,
    ),
  );

  Future<void> signOut() async {
    await _repository.signOut();
    _session = null;
    notifyListeners();
  }

  Future<String?> _run(Future<SessionModel> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      _session = await action();
      return null;
    } catch (error) {
      return _messageFor(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageFor(Object error) => switch (error) {
    AccessDenied() => 'Este acesso não está liberado para o perfil escolhido.',
    FirebaseAuthException(
      code: 'invalid-credential' || 'wrong-password' || 'user-not-found',
    ) =>
      'Dados de acesso incorretos.',
    FirebaseAuthException(code: 'network-request-failed') =>
      'Sem conexão com a internet. Tente novamente',
    FirebaseAuthException(code: 'too-many-requests') =>
      'Muitas tentativas. Aguarde um pouco e tente novamente.',
    _ => 'Não foi possível entrar. Tente novamente',
  };
}
