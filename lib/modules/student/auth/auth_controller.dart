import 'package:flutter/material.dart';

class StudentAuthController {
  final formKey = GlobalKey<FormState>();

  String avatarPath = 'panda.svg';
  String nickname = '';

  String? validateNickname(String? value) =>
      value == null || value.trim().isEmpty
      ? 'O codinome não pode ser vazio'
      : null;

  void onChange({String? avatar, String? name}) {
    avatarPath = avatar ?? avatarPath;
    nickname = name ?? nickname;
  }

  /// Valida o formulário. Retorna `true` se os dados estão corretos.
  bool submit() => formKey.currentState?.validate() ?? false;
}
