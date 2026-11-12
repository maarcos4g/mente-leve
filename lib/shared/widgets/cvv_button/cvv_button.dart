import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pílula "Ajuda (CVV)" que disca 188 pelo discador nativo.
///
/// Widget único para a área do aluno: o container das telas inclui este botão
/// em vez de repetir em cada tela.
class CvvButton extends StatelessWidget {
  const CvvButton({super.key, this.onPressed});

  static final Uri cvvUri = Uri(scheme: 'tel', path: '188');

  /// Permite trocar a ação (testes). Por padrão abre o discador.
  final VoidCallback? onPressed;

  /// Abre o discador nativo com o 188. Devolve `false` quando o aparelho não
  /// tem discador (ou ele não abre), sem lançar erro.
  static Future<bool> dial() async {
    try {
      return await launchUrl(cvvUri);
    } catch (_) {
      return false;
    }
  }

  Future<void> _dial(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await dial();
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o discador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajuda CVV, ligar para 188',
      child: Material(
        color: AppColors.sky500,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed ?? () => _dial(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 34),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.phone,
                    size: 16,
                    color: AppColors.zinc50,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Ajuda (CVV)',
                    style: AppTextStyles.captionXsMedium.copyWith(
                      color: AppColors.zinc50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
