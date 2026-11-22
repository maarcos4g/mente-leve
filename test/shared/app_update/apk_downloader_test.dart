import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mente_leve/shared/app_update/apk_downloader.dart';
import 'package:mente_leve/shared/app_update/release_info.dart';

void main() {
  late Directory cache;
  final bytes = utf8.encode('conteudo do apk ' * 100);

  setUp(() => cache = Directory.systemTemp.createTempSync('apk_downloader_'));
  tearDown(() {
    if (cache.existsSync()) cache.deleteSync(recursive: true);
  });

  ReleaseInfo release({int? size, String? hash}) => ReleaseInfo(
    tag: 'v1.1.0',
    apkName: 'mente-leve.apk',
    apkUrl: Uri.parse('https://example.com/mente-leve.apk'),
    apkSize: size,
    sha256: hash,
  );

  ApkDownloader downloader(
    Future<http.StreamedResponse> Function(http.BaseRequest) handler, {
    Duration stall = const Duration(seconds: 5),
  }) => ApkDownloader(
    client: MockClient.streaming((request, _) => handler(request)),
    cacheDirectory: () async => cache,
    stallTimeout: stall,
  );

  Future<http.StreamedResponse> ok(List<int> body, {int status = 200}) async {
    // Entrega em pedaços para exercitar o progresso.
    Stream<List<int>> chunks() async* {
      for (var i = 0; i < body.length; i += 400) {
        yield body.sublist(i, i + 400 > body.length ? body.length : i + 400);
      }
    }

    return http.StreamedResponse(
      chunks(),
      status,
      contentLength: body.length,
    );
  }

  test('baixa o APK, informa o progresso e confere tamanho e hash', () async {
    final progress = <double?>[];
    final file = await downloader((_) => ok(bytes)).download(
      release(size: bytes.length, hash: sha256.convert(bytes).toString()),
      onProgress: progress.add,
    );

    expect(file.readAsBytesSync(), bytes);
    expect(file.path, startsWith(cache.path));
    expect(progress.first, 0);
    expect(progress.last, 1);
    expect(progress.length, greaterThan(2));
    final values = progress.whereType<double>().toList();
    for (var i = 1; i < values.length; i++) {
      expect(values[i], greaterThanOrEqualTo(values[i - 1]));
    }
  });

  test('aceita release sem tamanho nem hash informados', () async {
    final file = await downloader((_) => ok(bytes)).download(release());
    expect(file.existsSync(), isTrue);
  });

  test('apaga o arquivo se o tamanho não bater', () async {
    final subject = downloader((_) => ok(bytes));
    await expectLater(
      subject.download(release(size: bytes.length + 1)),
      throwsA(isA<ApkDownloadException>()),
    );
    expect(Directory('${cache.path}/mente_leve_update').listSync(), isEmpty);
  });

  test('apaga o arquivo se o hash não bater', () async {
    final subject = downloader((_) => ok(bytes));
    await expectLater(
      subject.download(release(hash: 'a' * 64)),
      throwsA(isA<ApkDownloadException>()),
    );
    expect(Directory('${cache.path}/mente_leve_update').listSync(), isEmpty);
  });

  test('falha com resposta que não é 200', () async {
    await expectLater(
      downloader((_) => ok(const [], status: 404)).download(release()),
      throwsA(isA<ApkDownloadException>()),
    );
  });

  test('desiste se o download travar sem receber dados', () async {
    final subject = downloader(
      (_) => Completer<http.StreamedResponse>().future,
      stall: const Duration(milliseconds: 50),
    );
    await expectLater(
      subject.download(release()),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('um novo download limpa o APK anterior', () async {
    final subject = downloader((_) => ok(bytes));
    final old = File('${cache.path}/mente_leve_update/velho.apk')
      ..createSync(recursive: true);
    await subject.download(release());
    expect(old.existsSync(), isFalse);
  });
}
