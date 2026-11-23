import 'package:flutter_test/flutter_test.dart';
import 'package:mente_leve/shared/app_update/app_version.dart';
import 'package:mente_leve/shared/app_update/release_info.dart';

void main() {
  group('AppVersion.tryParse', () {
    test('lê tag com prefixo v', () {
      expect(AppVersion.tryParse('v1.2.3'), const AppVersion(1, 2, 3));
    });

    test('ignora build e pré-lançamento', () {
      expect(AppVersion.tryParse('1.2.3+4'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('v2.0.0-rc1'), const AppVersion(2, 0, 0));
    });

    test('completa partes que faltam com zero', () {
      expect(AppVersion.tryParse('v1.2'), const AppVersion(1, 2, 0));
      expect(AppVersion.tryParse('3'), const AppVersion(3, 0, 0));
    });

    test('devolve null para texto que não é versão', () {
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('latest'), isNull);
      expect(AppVersion.tryParse('release-1.2.3'), isNull);
    });
  });

  group('isNewerVersion', () {
    bool newer(String remote, String local) =>
        isNewerVersion(remoteTag: remote, localVersion: local);

    test('detecta versão superior em cada parte', () {
      expect(newer('v1.0.1', '1.0.0'), isTrue);
      expect(newer('v1.1.0', '1.0.9'), isTrue);
      expect(newer('v2.0.0', '1.9.9'), isTrue);
    });

    test('compara números e não texto', () {
      expect(newer('v1.10.0', '1.9.0'), isTrue);
      expect(newer('v1.9.0', '1.10.0'), isFalse);
    });

    test('igual ou inferior não é atualização', () {
      expect(newer('v1.0.0', '1.0.0'), isFalse);
      expect(newer('v1.0.0', '1.0.0+7'), isFalse);
      expect(newer('v0.9.0', '1.0.0'), isFalse);
    });

    test('tag ou versão inválida é ignorada', () {
      expect(newer('abc', '1.0.0'), isFalse);
      expect(newer('v1.0.1', 'abc'), isFalse);
    });
  });

  group('ReleaseInfo.tryParse', () {
    Map<String, dynamic> json({
      String tag = 'v1.2.0',
      List<Map<String, dynamic>>? assets,
      bool draft = false,
      bool prerelease = false,
    }) => {
      'tag_name': tag,
      'name': 'Versão 1.2.0',
      'draft': draft,
      'prerelease': prerelease,
      'assets': assets ??
          [
            {
              'name': 'mente-leve-v1.2.0.apk',
              'browser_download_url':
                  'https://github.com/maarcos4g/mente-leve/releases/download/v1.2.0/mente-leve-v1.2.0.apk',
              'size': 1234,
              'digest': 'sha256:${'A' * 64}',
            },
          ],
    };

    test('lê tag, apk, tamanho e hash', () {
      final release = ReleaseInfo.tryParse(json())!;
      expect(release.tag, 'v1.2.0');
      expect(release.name, 'Versão 1.2.0');
      expect(release.apkName, 'mente-leve-v1.2.0.apk');
      expect(release.apkUrl.scheme, 'https');
      expect(release.apkSize, 1234);
      expect(release.sha256, 'a' * 64);
    });

    test('escolhe o primeiro asset .apk e ignora os outros', () {
      final release = ReleaseInfo.tryParse(
        json(
          assets: [
            {
              'name': 'notas.txt',
              'browser_download_url': 'https://example.com/notas.txt',
            },
            {
              'name': 'app.APK',
              'browser_download_url': 'https://example.com/app.APK',
            },
          ],
        ),
      );
      expect(release?.apkName, 'app.APK');
      expect(release?.apkSize, isNull);
      expect(release?.sha256, isNull);
    });

    test('devolve null sem apk, com rascunho ou pré-lançamento', () {
      expect(ReleaseInfo.tryParse(json(assets: [])), isNull);
      expect(ReleaseInfo.tryParse(json(draft: true)), isNull);
      expect(ReleaseInfo.tryParse(json(prerelease: true)), isNull);
    });

    test('recusa download sem HTTPS', () {
      final release = ReleaseInfo.tryParse(
        json(
          assets: [
            {
              'name': 'app.apk',
              'browser_download_url': 'http://example.com/app.apk',
            },
          ],
        ),
      );
      expect(release, isNull);
    });

    test('descarta hash fora do formato', () {
      final release = ReleaseInfo.tryParse(
        json(
          assets: [
            {
              'name': 'app.apk',
              'browser_download_url': 'https://example.com/app.apk',
              'digest': 'md5:abc',
            },
          ],
        ),
      )!;
      expect(release.sha256, isNull);
    });

    test('devolve null para JSON fora do esperado', () {
      expect(ReleaseInfo.tryParse(null), isNull);
      expect(ReleaseInfo.tryParse([]), isNull);
      expect(ReleaseInfo.tryParse({'tag_name': 1}), isNull);
      expect(ReleaseInfo.tryParse({'tag_name': 'v1.0.0'}), isNull);
    });
  });
}
