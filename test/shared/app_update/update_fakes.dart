import 'dart:async';
import 'dart:io';

import 'package:mente_leve/shared/app_update/apk_downloader.dart';
import 'package:mente_leve/shared/app_update/apk_installer.dart';
import 'package:mente_leve/shared/app_update/app_update_repository.dart';
import 'package:mente_leve/shared/app_update/release_info.dart';

final testRelease = ReleaseInfo(
  tag: 'v1.1.0',
  apkName: 'mente-leve.apk',
  apkUrl: Uri.parse('https://example.com/mente-leve.apk'),
);

class FakeRepository implements AppUpdateRepository {
  FakeRepository(this.result);

  ReleaseInfo? result;
  Object? error;
  int calls = 0;
  String? askedWith;

  @override
  Future<ReleaseInfo?> checkForUpdate(String currentVersion) async {
    calls++;
    askedWith = currentVersion;
    if (error != null) throw error!;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDownloader implements ApkDownloader {
  FakeDownloader(this.file);

  final File file;
  Object? error;
  int calls = 0;

  /// Quando definido, o download espera este completer (para testar a UI
  /// durante o progresso).
  Completer<void>? gate;

  @override
  Future<File> download(
    ReleaseInfo release, {
    void Function(double? progress)? onProgress,
  }) async {
    calls++;
    if (error != null) throw error!;
    onProgress?.call(0.5);
    await gate?.future;
    onProgress?.call(1);
    return file;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeInstaller implements ApkInstaller {
  InstallResult result = InstallResult.started;
  int calls = 0;

  @override
  Future<InstallResult> install(File apk) async {
    calls++;
    return result;
  }
}

