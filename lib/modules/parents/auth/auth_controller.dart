import 'package:flutter/material.dart';

class ParentsAuthController {
  final formKey = GlobalKey<FormState>();

  String? validateIdentification(String? value) =>
      value == null || value.trim().isEmpty
      ? 'O número de identificação não pode ser vazio'
      : null;

  String? validatePassword(String? value) =>
      value == null || value.isEmpty ? 'A senha não pode ser vazia' : null;

  /// Valida o formulário. Retorna `true` se os dados estão corretos.
  bool login() => formKey.currentState?.validate() ?? false;
}
