import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mente_leve/shared/app_update/release_info.dart';
import 'package:path_provider/path_provider.dart';

/// Falha ao baixar ou conferir o APK.
class ApkDownloadException implements Exception {
  const ApkDownloadException(this.message);

  final String message;

  @override
  String toString() => 'ApkDownloadException: $message';
}

/// Baixa o APK de uma release para o cache do app e confere a integridade.
class ApkDownloader {
  ApkDownloader({
    http.Client? client,
    Future<Directory> Function()? cacheDirectory,
    this.stallTimeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client(),
       _cacheDirectory = cacheDirectory ?? getTemporaryDirectory;

  final http.Client _client;
  final Future<Directory> Function() _cacheDirectory;

  /// Tempo máximo sem receber nenhum dado antes de desistir do download.
  final Duration stallTimeout;

  /// Baixa o APK de [release], chamando [onProgress] com valores de 0 a 1
  /// (ou `null`, se o tamanho total for desconhecido). Devolve o arquivo.
  ///
  /// Lança [ApkDownloadException] se a resposta, o tamanho ou o hash não
  /// baterem. O arquivo incompleto ou inválido é apagado.
  Future<File> download(
    ReleaseInfo release, {
    void Function(double? progress)? onProgress,
  }) async {
    final directory = Directory(
      '${(await _cacheDirectory()).path}${Platform.pathSeparator}mente_leve_update',
    );
    if (directory.existsSync()) directory.deleteSync(recursive: true);
    await directory.create(recursive: true);

    final file = File(
      '${directory.path}${Platform.pathSeparator}${_safeName(release.apkName)}',
    );

    try {
      final response = await _client
          .send(http.Request('GET', release.apkUrl))
          .timeout(stallTimeout);
      if (response.statusCode != 200) {
        throw ApkDownloadException('HTTP ${response.statusCode}');
      }

      final total = response.contentLength ?? release.apkSize;
      var received = 0;
      onProgress?.call(total == null ? null : 0);

      final sink = file.openWrite();
      try {
        await for (final chunk in response.stream.timeout(stallTimeout)) {
          sink.add(chunk);
          received += chunk.length;
          if (total != null && total > 0) {
            onProgress?.call((received / total).clamp(0.0, 1.0));
          }
        }
      } finally {
        await sink.close();
      }

      await _verify(file, release);
      onProgress?.call(1);
      return file;
    } catch (_) {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    }
  }

  Future<void> _verify(File file, ReleaseInfo release) async {
    final size = release.apkSize;
    if (size != null && await file.length() != size) {
      throw const ApkDownloadException('tamanho do arquivo diferente do esperado');
    }
    final expected = release.sha256;
    if (expected != null) {
      final digest = await sha256.bind(file.openRead()).first;
      if (digest.toString() != expected) {
        throw const ApkDownloadException('hash SHA-256 diferente do esperado');
      }
    }
  }

  /// Só o nome do arquivo, sem separadores de caminho.
  static String _safeName(String name) {
    final cleaned = name.split(RegExp(r'[\\/]')).last.trim();
    return cleaned.isEmpty ? 'mente-leve.apk' : cleaned;
  }

  void close() => _client.close();
}
