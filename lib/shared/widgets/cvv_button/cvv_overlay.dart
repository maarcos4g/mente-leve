import 'package:flutter/material.dart';
import 'package:mente_leve/shared/widgets/cvv_button/cvv_button.dart';

/// Sobrepõe o botão "Ajuda (CVV)" a qualquer tela do app (RF05).
///
/// Usado em `MaterialApp.builder`, fica acima do Navigator e, por isso,
/// permanece visível em todas as rotas, sem cada tela precisar incluí-lo.
/// A discagem usa o discador nativo (`tel:188`) e não depende de internet.
class CvvOverlay extends StatelessWidget {
  const CvvOverlay({super.key, required this.child, this.onCvvPressed});

  final Widget child;

  /// Troca a ação do botão (testes). Por padrão abre o discador em 188.
  final VoidCallback? onCvvPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          right: 24,
          bottom: 52,
          child: CvvButton(onPressed: onCvvPressed),
        ),
      ],
    );
  }
}
