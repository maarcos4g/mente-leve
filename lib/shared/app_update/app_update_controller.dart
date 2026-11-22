import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mente_leve/shared/app_update/apk_downloader.dart';
import 'package:mente_leve/shared/app_update/apk_installer.dart';
import 'package:mente_leve/shared/app_update/app_update_repository.dart';
import 'package:mente_leve/shared/app_update/release_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum AppUpdateStatus {
  /// Nada a fazer: sem atualização ou verificação ainda não terminou.
  idle,

  /// Há uma versão nova, esperando a resposta do aluno.
  available,

  /// Baixando o APK.
  downloading,

  /// Download pronto, abrindo o instalador (e pedindo a permissão, se faltar).
  installing,

  /// O instalador do Android foi aberto.
  installerOpened,

  /// O aluno não liberou "Instalar apps desconhecidos".
  permissionDenied,

  /// O download ou a abertura do instalador falhou.
  failed,
}

/// Estado da atualização in-app: verifica a release mais recente, baixa o
/// APK e abre o instalador. Só atua no Android.
class AppUpdateController extends ChangeNotifier {
  AppUpdateController({
    required this._repository,
    required this._downloader,
    required this._installer,
    Future<String> Function()? currentVersion,
    bool? isSupported,
  }) : _currentVersion = currentVersion ?? _installedVersion,
       _isSupported =
           isSupported ??
           (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final AppUpdateRepository _repository;
  final ApkDownloader _downloader;
  final ApkInstaller _installer;
  final Future<String> Function() _currentVersion;
  final bool _isSupported;

  AppUpdateStatus _status = AppUpdateStatus.idle;
  ReleaseInfo? _release;
  double? _progress;
  File? _apk;
  bool _checked = false;

  AppUpdateStatus get status => _status;

  /// Versão nova encontrada, quando houver.
  ReleaseInfo? get release => _release;

  /// Progresso do download de 0 a 1, ou `null` se o tamanho é desconhecido.
  double? get progress => _progress;

  static Future<String> _installedVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  /// Consulta o GitHub uma vez por execução do app. Nunca lança: qualquer
  /// falha deixa o app como está.
  Future<ReleaseInfo?> check() async {
    if (!_isSupported || _checked) return _release;
    _checked = true;
    try {
      final release = await _repository.checkForUpdate(await _currentVersion());
      if (release == null) return null;
      _release = release;
      _set(AppUpdateStatus.available);
      return release;
    } catch (error) {
      debugPrint('Verificação de atualização ignorada: $error');
      return null;
    }
  }

  /// Baixa o APK e abre o instalador. Também serve para tentar de novo depois
  /// de uma falha ou de a permissão ser negada.
  Future<void> startUpdate() async {
    final release = _release;
    if (release == null) return;
    if (_status == AppUpdateStatus.downloading ||
        _status == AppUpdateStatus.installing) {
      return;
    }

    try {
      var apk = _apk;
      if (apk == null || !apk.existsSync()) {
        _progress = 0;
        _set(AppUpdateStatus.downloading);
        apk = await _downloader.download(
          release,
          onProgress: (value) {
            _progress = value;
            notifyListeners();
          },
        );
        _apk = apk;
      }

      _set(AppUpdateStatus.installing);
      final result = await _installer.install(apk);
      _set(switch (result) {
        InstallResult.started => AppUpdateStatus.installerOpened,
        InstallResult.permissionDenied => AppUpdateStatus.permissionDenied,
        InstallResult.failed => AppUpdateStatus.failed,
      });
    } catch (error) {
      debugPrint('Falha na atualização: $error');
      _apk = null;
      _set(AppUpdateStatus.failed);
    }
  }

  /// O aluno escolheu "Agora não": segue sem atualizar até a próxima abertura.
  void dismiss() {
    if (_status == AppUpdateStatus.downloading ||
        _status == AppUpdateStatus.installing) {
      return;
    }
    _set(AppUpdateStatus.idle);
  }

  void _set(AppUpdateStatus status) {
    _status = status;
    notifyListeners();
  }
}
