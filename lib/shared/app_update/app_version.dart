/// Versão no formato `major.minor.patch`, usada para comparar a tag de uma
/// release do GitHub (`v1.2.3`) com o `versionName` instalado (`1.2.3`).
///
/// Pré-lançamento (`-rc1`) e build (`+4`) são ignorados: o app só se atualiza
/// quando o número principal da versão remota é maior.
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^[vV]?(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:[-+].*)?$');

  /// Lê `v1.2.3`, `1.2.3+4`, `1.2` ou `1`. Devolve `null` se não for versão.
  static AppVersion? tryParse(String text) {
    final match = _pattern.firstMatch(text.trim());
    if (match == null) return null;
    return AppVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2) ?? '0'),
      int.parse(match.group(3) ?? '0'),
    );
  }

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// `true` se [remoteTag] é uma versão superior à instalada. Qualquer texto
/// que não seja versão devolve `false`, para a verificação ser ignorada.
bool isNewerVersion({required String remoteTag, required String localVersion}) {
  final remote = AppVersion.tryParse(remoteTag);
  final local = AppVersion.tryParse(localVersion);
  if (remote == null || local == null) return false;
  return remote > local;
}
