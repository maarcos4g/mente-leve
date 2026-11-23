/// Release do GitHub com um APK anexado, já validada para uso no app.
class ReleaseInfo {
  const ReleaseInfo({
    required this.tag,
    required this.apkName,
    required this.apkUrl,
    this.apkSize,
    this.sha256,
    this.name,
  });

  /// Tag da release (`v1.2.3`).
  final String tag;

  /// Título da release, quando o autor deu um.
  final String? name;

  /// Nome do arquivo `.apk` anexado.
  final String apkName;

  /// `browser_download_url` do APK.
  final Uri apkUrl;

  /// Tamanho em bytes informado pelo GitHub, usado para conferir o download.
  final int? apkSize;

  /// Hash SHA-256 (hexadecimal, minúsculo) informado pelo GitHub em `digest`.
  final String? sha256;

  /// Lê o JSON de `GET /repos/{dono}/{repo}/releases/latest`. Devolve `null`
  /// se a release for rascunho, pré-lançamento, não tiver `.apk` ou tiver
  /// dados fora do esperado.
  static ReleaseInfo? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    if (json['draft'] == true || json['prerelease'] == true) return null;

    final tag = json['tag_name'];
    if (tag is! String || tag.trim().isEmpty) return null;

    final assets = json['assets'];
    if (assets is! List) return null;

    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final assetName = asset['name'];
      final url = asset['browser_download_url'];
      if (assetName is! String || url is! String) continue;
      if (!assetName.toLowerCase().endsWith('.apk')) continue;

      final uri = Uri.tryParse(url);
      // Só baixa por HTTPS: o APK nunca trafega em texto puro.
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) continue;

      final size = asset['size'];
      final digest = asset['digest'];
      final name = json['name'];
      return ReleaseInfo(
        tag: tag.trim(),
        name: name is String && name.trim().isNotEmpty ? name.trim() : null,
        apkName: assetName,
        apkUrl: uri,
        apkSize: size is int && size > 0 ? size : null,
        sha256: _sha256From(digest),
      );
    }
    return null; 
  }

  static String? _sha256From(Object? digest) {
    if (digest is! String) return null;
    const prefix = 'sha256:';
    if (!digest.startsWith(prefix)) return null;
    final hex = digest.substring(prefix.length).toLowerCase();
    return RegExp(r'^[0-9a-f]{64}$').hasMatch(hex) ? hex : null;
  }
}
