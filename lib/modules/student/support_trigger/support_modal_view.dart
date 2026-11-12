import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mente_leve/modules/student/home/home_controller.dart';
import 'package:mente_leve/modules/student/support_trigger/support_trigger_controller.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';
import 'package:provider/provider.dart';

/// Chamado pelo registro de humor logo depois de salvar (UC20, RN11).
///
/// Não adiciona passos ao registro (RN09): o humor já está salvo quando a
/// regra é avaliada, e o modal fecha com um toque. [availableRoutes] são as
/// rotas registradas em `AppWidget.routes`, como na Home.
Future<void> showSupportModalIfNeeded(
  BuildContext context, {
  required Set<String> availableRoutes,
  String? avatar,
  SupportTriggerController? controller,
}) async {
  final trigger = controller ?? context.read<SupportTriggerController>();
  if (!await trigger.shouldShowAfterMoodSaved()) return;
  if (!context.mounted) return;

  await trigger.markShown();
  if (!context.mounted) return;

  final route = await showSupportModal(
    context,
    availableRoutes: availableRoutes,
    avatar: avatar,
  );
  if (route != null && context.mounted) {
    Navigator.of(context).pushNamed(route);
  }
}

/// Mostra o modal. Devolve a rota escolhida pelo aluno (Canais e FAQ ou
/// relato anônimo), ou `null` se ele fechou ou ligou para o CVV.
Future<String?> showSupportModal(
  BuildContext context, {
  required Set<String> availableRoutes,
  String? avatar,
  Future<bool> Function()? onCallCvv,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => SupportModal(
      availableRoutes: availableRoutes,
      avatar: avatar,
      onCallCvv: onCallCvv,
    ),
  );
}

/// Modal de apoio, na voz do mascote. Só acolhe e encaminha: não faz
/// diagnóstico nem avalia o aluno.
class SupportModal extends StatefulWidget {
  const SupportModal({
    super.key,
    this.availableRoutes = const {},
    this.avatar,
    this.onCallCvv,
  });

  static const title = 'Estou aqui com você';
  static const message =
      'Percebi que os últimos dias têm sido pesados. Você não precisa passar '
      'por isso só. Conversar com alguém pode ajudar.';
  static const cvvInfo =
      'O CVV atende 24 horas, a ligação é gratuita e você não precisa dizer '
      'seu nome.';
  static const callLabel = 'Ligar para o CVV 188';
  static const channelsLabel = 'Ver canais de apoio e FAQ';
  static const reportLabel = 'Enviar relato anônimo à escola';
  static const dismissLabel = 'Agora não';
  static const dialerFailedMessage =
      'Não consegui abrir o discador neste aparelho. Você pode ligar para o '
      '188 de qualquer telefone, a ligação é gratuita.';

  /// Rotas já registradas no app. Os atalhos de Canais e FAQ e de relato
  /// anônimo só aparecem quando a tela existe.
  final Set<String> availableRoutes;

  /// Avatar escolhido pelo aluno (nome do arquivo em `assets/avatars/`).
  final String? avatar;

  /// Troca a discagem (testes). Por padrão usa `CvvButton.dial`.
  final Future<bool> Function()? onCallCvv;

  @override
  State<SupportModal> createState() => _SupportModalState();
}

class _SupportModalState extends State<SupportModal> {
  bool _calling = false;
  bool _dialerFailed = false;

  Future<void> _callCvv() async {
    if (_calling) return;
    setState(() {
      _calling = true;
      _dialerFailed = false;
    });
    final opened = await (widget.onCallCvv ?? CvvButton.dial)();
    if (!mounted) return;
    if (opened) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _calling = false;
      _dialerFailed = true;
    });
  }

  void _close([String? route]) => Navigator.of(context).pop(route);

  @override
  Widget build(BuildContext context) {
    final palette = _SupportPalette.of(context);
    final routes = widget.availableRoutes;

    return Dialog(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _Mascot(
                asset:
                    'assets/avatars/${widget.avatar ?? HomeController.defaultAvatar}',
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                SupportModal.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(color: palette.text),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SupportModal.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionMedium.copyWith(
                color: palette.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SupportModal.cvvInfo,
              textAlign: TextAlign.center,
              style: AppTextStyles.textXs.copyWith(
                color: palette.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _calling ? null : _callCvv,
              style: _buttonStyle(
                FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary,
                  disabledBackgroundColor: palette.primary.withValues(
                    alpha: 0.6,
                  ),
                  disabledForegroundColor: palette.onPrimary,
                ),
              ),
              icon: const Icon(LucideIcons.phone, size: 20),
              label: const Text(SupportModal.callLabel),
            ),
            if (_dialerFailed) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  SupportModal.dialerFailedMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textXs.copyWith(
                    color: palette.text,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (routes.contains(HomeController.faqRoute)) ...[
              const SizedBox(height: 12),
              _SecondaryAction(
                icon: LucideIcons.lifeBuoy,
                label: SupportModal.channelsLabel,
                palette: palette,
                onPressed: () => _close(HomeController.faqRoute),
              ),
            ],
            if (routes.contains(HomeController.reportRoute)) ...[
              const SizedBox(height: 12),
              _SecondaryAction(
                icon: LucideIcons.messageCircleHeart,
                label: SupportModal.reportLabel,
                palette: palette,
                onPressed: () => _close(HomeController.reportRoute),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _close,
              style: _buttonStyle(
                TextButton.styleFrom(foregroundColor: palette.secondaryText),
              ),
              child: const Text(SupportModal.dismissLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Altura mínima de 48dp (área de toque) e texto que pode quebrar linha
/// quando o aluno aumenta a fonte do sistema.
ButtonStyle _buttonStyle(ButtonStyle base) => base.copyWith(
  minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
  padding: const WidgetStatePropertyAll(
    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  textStyle: WidgetStatePropertyAll(AppTextStyles.buttonHeading),
  shape: const WidgetStatePropertyAll(StadiumBorder()),
);

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.palette,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final _SupportPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: _buttonStyle(
        OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary, width: 1.5),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}

/// Avatar do aluno sobre o acento rosa da marca. Decorativo para leitores de
/// tela: o texto do modal já diz tudo.
class _Mascot extends StatelessWidget {
  const _Mascot({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.accentPink,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(asset, width: 60, height: 60),
      ),
    );
  }
}

/// Cores do modal com contraste WCAG AA nos dois modos. Segue o modo escuro
/// do sistema (RN10), já que o app ainda não define um tema escuro.
class _SupportPalette {
  const _SupportPalette({
    required this.surface,
    required this.text,
    required this.secondaryText,
    required this.primary,
    required this.onPrimary,
  });

  factory _SupportPalette.of(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return dark ? _dark : _light;
  }

  // Branco sobre sky700: 5,9:1. sky700 sobre zinc50: 5,6:1.
  static const _light = _SupportPalette(
    surface: AppColors.zinc50,
    text: AppColors.zinc950,
    secondaryText: AppColors.slate600,
    primary: AppColors.sky700,
    onPrimary: Colors.white,
  );

  // zinc950 sobre sky500: 7,4:1. sky500 sobre zinc900: 6,5:1.
  static const _dark = _SupportPalette(
    surface: AppColors.zinc900,
    text: AppColors.zinc50,
    secondaryText: AppColors.zinc100,
    primary: AppColors.sky500,
    onPrimary: AppColors.zinc950,
  );

  final Color surface;
  final Color text;
  final Color secondaryText;
  final Color primary;
  final Color onPrimary;
}
