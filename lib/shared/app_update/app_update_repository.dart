import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mente_leve/shared/app_update/app_version.dart';
import 'package:mente_leve/shared/app_update/release_info.dart';

/// Consulta a API pública de Releases do GitHub, sem token nem login.
///
/// Qualquer falha (sem internet, timeout, limite de requisições, JSON
/// inesperado) devolve `null`: a verificação de atualização nunca pode
/// atrapalhar o uso do app.
class AppUpdateRepository {
  AppUpdateRepository({
    http.Client? client,
    this.owner = 'maarcos4g',
    this.repo = 'mente-leve',
    this.timeout = const Duration(seconds: 5),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String owner;
  final String repo;

  /// Tempo máximo da consulta. Curto de propósito: sem rede, o app segue.
  final Duration timeout;

  Uri get latestReleaseUri =>
      Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest');

  /// Última release publicada, ou `null` se não houver ou se a consulta falhar.
  Future<ReleaseInfo?> fetchLatest() async {
    try {
      final response = await _client
          .get(
            latestReleaseUri,
            headers: const {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      return ReleaseInfo.tryParse(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (error) {
      // Offline, timeout, rate limit, JSON inválido: ignora em silêncio.
      debugPrint('Verificação de atualização ignorada: $error');
      return null;
    }
  }

  /// A release mais recente, só se for superior a [currentVersion].
  Future<ReleaseInfo?> checkForUpdate(String currentVersion) async {
    final latest = await fetchLatest();
    if (latest == null) return null;
    final newer = isNewerVersion(
      remoteTag: latest.tag,
      localVersion: currentVersion,
    );
    return newer ? latest : null;
  }

  void close() => _client.close();
}
