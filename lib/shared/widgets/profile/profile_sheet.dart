import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:mente_leve/shared/models/session_model.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:provider/provider.dart';

/// Abre o perfil da sessão ativa (aluno, psicóloga ou responsável) com a
/// opção de sair da conta. Não faz nada se não houver sessão.
Future<void> showProfileSheet(BuildContext context) {
  final session = context.read<AuthNotifier>().session;
  if (session == null) return Future.value();

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.zinc50,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ProfileSheet(session: session),
  );
}

/// Conteúdo do perfil. O aluno é anônimo: só codinome e avatar. Os perfis
/// institucionais mostram nome, e-mail e papel.
class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key, required this.session});

  final SessionModel session;

  static String roleLabel(Role role) => switch (role) {
    Role.student => 'Aluno',
    Role.parent => 'Responsável',
    Role.psychologist => 'Psicóloga',
  };

  @override
  Widget build(BuildContext context) {
    final (title, lines) = switch (session) {
      StudentSessionModel(:final user) => (user.nickname, ['Perfil anônimo']),
      InstitutionalSession(:final user, :final email) => (
        user.name,
        [?email, roleLabel(user.role)],
      ),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _Avatar(session: session)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleBoldHeading.copyWith(
                color: AppColors.zinc950,
              ),
            ),
            for (final line in lines)
              Text(
                line,
                textAlign: TextAlign.center,
                style: AppTextStyles.captionBody.copyWith(
                  color: AppColors.slate600,
                ),
              ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.zinc900,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => LogoutDialog(isStudent: session is StudentSessionModel),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthNotifier>();
    try {
      await auth.signOut();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível sair. Tente novamente.')),
      );
      return;
    }
    navigator.pushNamedAndRemoveUntil('/onboarding', (_) => false);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final avatar = switch (session) {
      StudentSessionModel(:final user) => SvgPicture.asset(
        'assets/avatars/${user.avatar}',
        width: 64,
        height: 64,
      ),
      InstitutionalSession() => const Icon(
        Icons.person,
        size: 48,
        color: AppColors.sky700,
      ),
    };

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(child: avatar),
    );
  }
}

/// Confirmação de logout. Devolve `true` ao confirmar. Para o aluno, avisa que
/// o perfil anônimo guardado no aparelho será removido.
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key, required this.isStudent});

  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sair da conta?'),
      content: Text(
        isStudent
            ? 'Seu perfil anônimo (codinome e avatar) será removido deste '
                  'aparelho. Para voltar, você precisará criar um novo perfil.'
            : 'Você voltará para a tela inicial e precisará entrar de novo '
                  'com seu e-mail e senha.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
