import 'package:flutter/material.dart';
import 'package:mente_leve/shared/models/local_user_model.dart';

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

  bool submit() => formKey.currentState?.validate() ?? false;

  LocalUserModel get profile =>
      LocalUserModel(nickname: nickname.trim(), avatar: avatarPath);
}
