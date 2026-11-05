import 'package:flutter/material.dart';
import 'package:mente_leve/shared/themes/app_text_styles.dart';
import 'package:mente_leve/shared/themes/tailwind_colors.dart';

/// Campo de texto padrão do app.
///
/// Mostra, opcionalmente, um [label] acima do campo. Aceita ícones à esquerda
/// ([prefixIcon]) e à direita ([suffixIcon]), tanto como [IconData] quanto
/// como widget ([prefix] / [suffix]), para casos como o botão de mostrar senha.
class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.maxLines = 1,
    this.borderRadius = 16,
    this.contentPadding,
  });

  final TextEditingController? controller;

  /// Texto exibido acima do campo.
  final String? label;
  final String? hint;

  /// Ícones simples (usam a cor `zinc500`).
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  /// Widgets personalizados. Têm prioridade sobre [prefixIcon] / [suffixIcon].
  final Widget? prefix;
  final Widget? suffix;

  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final int maxLines;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: TailwindColors.zinc400),
      borderRadius: BorderRadius.circular(borderRadius),
    );

    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            prefix ??
            (prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: TailwindColors.zinc500)),
        suffixIcon:
            suffix ??
            (suffixIcon == null
                ? null
                : Icon(suffixIcon, size: 18, color: TailwindColors.zinc500)),
        contentPadding: contentPadding,
        border: border,
        isDense: true,
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppTextStyles.captionBody),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
