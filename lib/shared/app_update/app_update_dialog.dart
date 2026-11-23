import 'package:flutter/material.dart';
import 'package:mente_leve/shared/app_update/app_update_controller.dart';
import 'package:mente_leve/shared/themes/app_colors.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';

/// Abre o modal de atualização se [controller] achou uma versão nova.
///
/// Não faz nada quando não há atualização. Fecha sozinho quando o instalador
/// do Android é aberto ou quando o aluno escolhe "Agora não".
Future<void> showAppUpdateDialogIfAvailable(
  BuildContext context,
  AppUpdateController controller,
) async {
  if (controller.status != AppUpdateStatus.available) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AppUpdateDialog(controller: controller),
  );
}

/// Modal acolhedor de atualização: convida, mostra o progresso do download
/// e, se algo falhar, tranquiliza e oferece tentar de novo.
class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({super.key, required this.controller});

  static const availableTitle = 'Temos novidades para você';
  static const availableMessage =
      'Uma versão nova do MenteLeve está pronta. Atualizar leva só um '
      'instante e tudo o que você guardou continua no seu aparelho.';
  static const downloadingTitle = 'Baixando a novidade';
  static const downloadingMessage =
      'Fique por aqui, é rápido. Não precisa fazer mais nada.';
  static const installingTitle = 'Quase lá';
  static const installingMessage =
      'Vou abrir o instalador do Android. Se ele pedir, libere a instalação '
      'do MenteLeve e toque em instalar.';
  static const permissionTitle = 'Falta só uma autorização';
  static const permissionMessage =
      'Para atualizar, o Android precisa da sua permissão para instalar o '
      'MenteLeve. Sem pressa: você pode tentar de novo quando quiser.';
  static const failedTitle = 'Não deu para atualizar agora';
  static const failedMessage =
      'Tudo bem, o app continua funcionando normalmente. Confira a internet '
      'e tente de novo quando puder.';
  static const updateLabel = 'Atualizar agora';
  static const retryLabel = 'Tentar de novo';
  static const dismissLabel = 'Agora não';

  final AppUpdateController controller;

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  AppUpdateController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_closeWhenInstallerOpens);
  }

  @override
  void dispose() {
    _controller.removeListener(_closeWhenInstallerOpens);
    super.dispose();
  }

  void _closeWhenInstallerOpens() {
    if (_controller.status == AppUpdateStatus.installerOpened && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _dismiss() {
    _controller.dismiss();
    Navigator.of(context).pop();
  }

  bool get _busy =>
      _controller.status == AppUpdateStatus.downloading ||
      _controller.status == AppUpdateStatus.installing;

  @override
  Widget build(BuildContext context) {
    final palette = _UpdatePalette.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final status = _controller.status;
        final content = _contentFor(status);

        return PopScope(
          canPop: !_busy,
          child: Dialog(
            backgroundColor: palette.surface,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: _Mascot()),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      content.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: palette.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      content.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: palette.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (status == AppUpdateStatus.downloading ||
                      status == AppUpdateStatus.installing) ...[
                    const SizedBox(height: 20),
                    _ProgressBar(
                      value: status == AppUpdateStatus.installing
                          ? 1
                          : _controller.progress,
                      palette: palette,
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (content.primaryLabel != null)
                    FilledButton(
                      onPressed: _controller.startUpdate,
                      style: _buttonStyle(
                        FilledButton.styleFrom(
                          backgroundColor: palette.primary,
                          foregroundColor: palette.onPrimary,
                        ),
                      ),
                      child: Text(content.primaryLabel!),
                    ),
                  if (!_busy) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _dismiss,
                      style: _buttonStyle(
                        TextButton.styleFrom(
                          foregroundColor: palette.secondaryText,
                        ),
                      ),
                      child: const Text(AppUpdateDialog.dismissLabel),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _Content _contentFor(AppUpdateStatus status) => switch (status) {
    AppUpdateStatus.downloading => const _Content(
      AppUpdateDialog.downloadingTitle,
      AppUpdateDialog.downloadingMessage,
    ),
    AppUpdateStatus.installing => const _Content(
      AppUpdateDialog.installingTitle,
      AppUpdateDialog.installingMessage,
    ),
    AppUpdateStatus.permissionDenied => const _Content(
      AppUpdateDialog.permissionTitle,
      AppUpdateDialog.permissionMessage,
      primaryLabel: AppUpdateDialog.retryLabel,
    ),
    AppUpdateStatus.failed => const _Content(
      AppUpdateDialog.failedTitle,
      AppUpdateDialog.failedMessage,
      primaryLabel: AppUpdateDialog.retryLabel,
    ),
    _ => const _Content(
      AppUpdateDialog.availableTitle,
      AppUpdateDialog.availableMessage,
      primaryLabel: AppUpdateDialog.updateLabel,
    ),
  };
}

class _Content {
  const _Content(this.title, this.message, {this.primaryLabel});

  final String title;
  final String message;
  final String? primaryLabel;
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

/// Barra de progresso com porcentagem. Sem tamanho total conhecido, fica
/// indeterminada.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.palette});

  final double? value;
  final _UpdatePalette palette;

  @override
  Widget build(BuildContext context) {
    final percent = value == null ? null : (value! * 100).round();
    return Semantics(
      label: 'Progresso do download',
      value: percent == null ? null : '$percent por cento',
      child: ExcludeSemantics(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                color: palette.primary,
                backgroundColor: palette.primary.withValues(alpha: 0.2),
              ),
            ),
            if (percent != null) ...[
              const SizedBox(height: 8),
              Text(
                '$percent%',
                style: AppTextStyles.textXs.copyWith(color: palette.text),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mascote da marca sobre o acento rosa. Decorativo para leitores de tela.
class _Mascot extends StatelessWidget {
  const _Mascot();

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
        child: Image.asset('assets/images/breno.png', width: 60, height: 60),
      ),
    );
  }
}

/// Mesmas cores do modal de apoio, com contraste WCAG AA nos dois modos.
class _UpdatePalette {
  const _UpdatePalette({
    required this.surface,
    required this.text,
    required this.secondaryText,
    required this.primary,
    required this.onPrimary,
  });

  factory _UpdatePalette.of(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return dark ? _dark : _light;
  }

  static const _light = _UpdatePalette(
    surface: AppColors.zinc50,
    text: AppColors.zinc950,
    secondaryText: AppColors.slate600,
    primary: AppColors.sky700,
    onPrimary: Colors.white,
  );

  static const _dark = _UpdatePalette(
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
