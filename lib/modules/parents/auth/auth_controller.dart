import 'package:flutter/material.dart';

class ParentsAuthController {
  final formKey = GlobalKey<FormState>();

  static const _emailDomain = 'parents.menteleve.app';

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  String emailFromIdentification(String value) =>
      '${_digits(value)}@$_emailDomain';

  String? validateIdentification(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O número de identificação não pode ser vazio';
    }
    return _digits(value).isEmpty ? 'Informe apenas os números' : null;
  }

  String? validatePassword(String? value) =>
      value == null || value.isEmpty ? 'A senha não pode ser vazia' : null;

  bool validate() => formKey.currentState?.validate() ?? false;
}
