import 'package:flutter/material.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';

/// Acompanha a pilha de rotas para saber qual tela está no topo.
///
/// O overlay fica acima do Navigator e não enxerga a rota atual por conta
/// própria; este observer publica o nome da rota do topo em [currentRoute].
class CvvRouteObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(null);
  final List<Route<dynamic>> _stack = [];

  void _publish() {
    // Callbacks do Navigator podem ocorrer durante o build; adia a notificação.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = _stack.isEmpty ? null : _stack.last.settings.name;
      if (currentRoute.value != name) currentRoute.value = name;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _publish();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _publish();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _publish();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) {
      _stack[index] = newRoute;
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
    _publish();
  }
}

/// Sobrepõe o botão "Ajuda (CVV)" às telas do app (RF05).
///
/// Usado em `MaterialApp.builder`, fica acima do Navigator e, por isso,
/// permanece visível ao navegar, sem cada tela precisar incluí-lo. Some nas
/// rotas que começam com [hiddenRoutePrefixes] (ex.: telas de login).
/// A discagem usa o discador nativo (`tel:188`) e não depende de internet.
class CvvOverlay extends StatelessWidget {
  const CvvOverlay({
    super.key,
    required this.child,
    required this.observer,
    this.hiddenRoutePrefixes = const ['/auth/'],
    this.onCvvPressed,
  });

  final Widget child;
  final CvvRouteObserver observer;

  /// Rotas cujo nome começa com algum destes prefixos não mostram o botão.
  final List<String> hiddenRoutePrefixes;

  /// Troca a ação do botão (testes). Por padrão abre o discador em 188.
  final VoidCallback? onCvvPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        ValueListenableBuilder<String?>(
          valueListenable: observer.currentRoute,
          builder: (context, route, _) {
            final hidden =
                route != null && hiddenRoutePrefixes.any(route.startsWith);
            if (hidden) return const SizedBox.shrink();
            return Positioned(
              right: 24,
              bottom: 52,
              child: CvvButton(onPressed: onCvvPressed),
            );
          },
        ),
      ],
    );
  }
}
