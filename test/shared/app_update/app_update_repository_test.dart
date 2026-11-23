import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mente_leve/shared/app_update/app_update_repository.dart';

String _body({String tag = 'v1.1.0', bool withApk = true}) => jsonEncode({
  'tag_name': tag,
  'name': 'Novidades',
  'draft': false,
  'prerelease': false,
  'assets': withApk
      ? [
          {
            'name': 'mente-leve.apk',
            'browser_download_url': 'https://example.com/mente-leve.apk',
            'size': 10,
          },
        ]
      : [],
});

AppUpdateRepository _repo(
  Future<http.Response> Function(http.Request) handler, {
  Duration timeout = const Duration(milliseconds: 200),
}) => AppUpdateRepository(client: MockClient(handler), timeout: timeout);

void main() {
  test('consulta o endpoint público releases/latest, sem autenticação', () async {
    http.Request? sent;
    final repo = _repo((request) async {
      sent = request;
      return http.Response(_body(), 200);
    });

    await repo.fetchLatest();

    expect(
      sent!.url.toString(),
      'https://api.github.com/repos/maarcos4g/mente-leve/releases/latest',
    );
    expect(sent!.headers.containsKey('Authorization'), isFalse);
    expect(sent!.headers['Accept'], 'application/vnd.github+json');
  });

  test('devolve a release quando a versão remota é superior', () async {
    final repo = _repo((_) async => http.Response(_body(tag: 'v1.1.0'), 200));
    final release = await repo.checkForUpdate('1.0.0');
    expect(release?.tag, 'v1.1.0');
    expect(release?.apkName, 'mente-leve.apk');
  });

  test('devolve null quando a versão é igual ou inferior', () async {
    final repo = _repo((_) async => http.Response(_body(tag: 'v1.0.0'), 200));
    expect(await repo.checkForUpdate('1.0.0'), isNull);
    expect(await repo.checkForUpdate('2.0.0'), isNull);
  });

  test('devolve null quando a release não tem apk', () async {
    final repo = _repo((_) async => http.Response(_body(withApk: false), 200));
    expect(await repo.checkForUpdate('1.0.0'), isNull);
  });

  test('ignora 404 (sem releases) e limite de requisições (403 e 429)', () async {
    for (final status in [404, 403, 429, 500]) {
      final repo = _repo((_) async => http.Response('{}', status));
      expect(await repo.checkForUpdate('1.0.0'), isNull, reason: '$status');
    }
  });

  test('ignora JSON malformado', () async {
    final repo = _repo((_) async => http.Response('<html>', 200));
    expect(await repo.checkForUpdate('1.0.0'), isNull);
  });

  test('ignora falta de internet', () async {
    final repo = _repo((_) async => throw const SocketException('offline'));
    expect(await repo.checkForUpdate('1.0.0'), isNull);
  });

  test('desiste depois do timeout curto', () async {
    final repo = _repo(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 50),
    );
    final stopwatch = Stopwatch()..start();
    expect(await repo.checkForUpdate('1.0.0'), isNull);
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  });
}
