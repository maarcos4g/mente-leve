import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

/// Resultado de tentar abrir o instalador do Android.
enum InstallResult {
  /// O instalador de pacotes foi aberto.
  started,

  /// O aluno não liberou "Instalar apps desconhecidos" para o MenteLeve.
  permissionDenied,

  /// Não foi possível abrir o instalador.
  failed,
}

/// Abre o instalador nativo para um APK já baixado.
abstract class ApkInstaller {
  Future<InstallResult> install(File apk);
}

/// Instalador do Android: pede "Instalar apps desconhecidos" só se ainda não
/// foi concedida e abre o APK pelo instalador de pacotes do sistema.
class AndroidApkInstaller implements ApkInstaller {
  const AndroidApkInstaller();

  static const _apkMimeType = 'application/vnd.android.package-archive';

  @override
  Future<InstallResult> install(File apk) async {
    try {
      var status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        // No Android 8+ abre a tela de configurações e só volta quando o
        // aluno retorna ao app.
        status = await Permission.requestInstallPackages.request();
      }
      if (!status.isGranted) return InstallResult.permissionDenied;

      final result = await OpenFilex.open(apk.path, type: _apkMimeType);
      return switch (result.type) {
        ResultType.done => InstallResult.started,
        ResultType.permissionDenied => InstallResult.permissionDenied,
        _ => InstallResult.failed,
      };
    } catch (error) {
      debugPrint('Falha ao abrir o instalador: $error');
      return InstallResult.failed;
    }
  }
}
