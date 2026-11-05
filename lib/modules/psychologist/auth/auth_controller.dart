import 'package:flutter/material.dart';

class PsychologistAuthController {
  final formKey = GlobalKey<FormState>();

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'O e-mail não pode ser vazio';
    if (!_emailRegex.hasMatch(email)) return 'Insira um e-mail válido';
    return null;
  }

  String? validatePassword(String? value) =>
      value == null || value.isEmpty ? 'A senha não pode ser vazia' : null;

  /// Valida o formulário. Retorna `true` se os dados estão corretos.
  bool login() => formKey.currentState?.validate() ?? false;
}
