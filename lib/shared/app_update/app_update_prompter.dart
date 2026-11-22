import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mente_leve/shared/app_update/app_update_controller.dart';
import 'package:mente_leve/shared/app_update/app_update_dialog.dart';

/// Decide quando mostrar o modal de atualização, uma vez por execução do app.
///
/// Dispara a verificação na inicialização, em paralelo à splash, e só abre o
/// modal quando há versão nova **e** o app está numa tela inicial
/// ([homeRoutes]). Assim a verificação não atrasa a entrada no app e o modal
/// nunca interrompe o aluno no meio do diário ou de uma conversa. Se a
/// resposta chegar depois, o modal espera o retorno a uma tela inicial.
class AppUpdatePrompter {
  AppUpdatePrompter({
    required this.controller,
    required this.navigatorKey,
    required this.currentRoute,
    required this.homeRoutes,
  });

  final AppUpdateController controller;
  final GlobalKey<NavigatorState> navigatorKey;

  /// Nome da rota no topo da pilha (`CvvRouteObserver.currentRoute`).
  final ValueListenable<String?> currentRoute;

  /// Rotas em que o modal pode aparecer.
  final Set<String> homeRoutes;

  bool _prompted = false;

  void start() {
    controller.addListener(_maybePrompt);
    currentRoute.addListener(_maybePrompt);
    // `check()` nunca lança: sem internet ou com falha na API, só não há modal.
    unawaited(controller.check());
  }

  void dispose() {
    controller.removeListener(_maybePrompt);
    currentRoute.removeListener(_maybePrompt);
  }

  void _maybePrompt() {
    if (_prompted) return;
    if (controller.status != AppUpdateStatus.available) return;
    if (!homeRoutes.contains(currentRoute.value)) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _prompted = true;
    unawaited(showAppUpdateDialogIfAvailable(context, controller));
  }
}
