import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final TextStyle textStyle;
  final IconData? icon;
  final Color backgroundColor;

  const ButtonWidget({super.key, this.onPressed, required this.label, required this.textStyle, this.icon, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          spacing: 24,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: textStyle.color, size: 24),
            Text(
              label,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
