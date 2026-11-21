import 'package:flutter/material.dart';
import 'package:mente_leve/shared/widgets/profile/profile_sheet.dart';

class PsychologistHomeView extends StatelessWidget {
  const PsychologistHomeView({super.key, this.user});

  /// Usuário institucional carregado do Firestore (`users/{uid}`).
  /// Quando omitido, lê automaticamente da sessão ativa em [AuthNotifier].
  final UserModel? user;

  UserModel? _resolveUser(BuildContext context) {
    if (user != null) return user;
    try {
      final session = context.watch<AuthNotifier>().session;
      if (session is InstitutionalSession) {
        return session.user;
      }
    } catch (_) {
      // Provider pode não estar presente em testes isolados.
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _resolveUser(context);
    final displayName = currentUser?.name.trim() ?? '';
    final greeting = displayName.isNotEmpty ? 'Olá, $displayName!' : 'Olá!';
    final photoUrl = currentUser?.photoUrl?.trim();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => showProfileSheet(context),
          ),
        ],
      ),
    );
  }
}
