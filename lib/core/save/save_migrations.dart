import 'package:arrowchime/core/save/save_data.dart';

/// Upgrades an older save's JSON to [currentSaveSchema] (`docs/05` §6), one
/// version at a time, so every old shape keeps loading.
///
/// * v1 (development builds): `{schemaVersion: 1, stars: {id: n}, coins: n}`
///   plus a flat `streak: n` and `lastPlayed`.
/// * v2: the full shape of `SaveData`; the streak became an object.
abstract final class SaveMigrations {
  /// Returns [json] upgraded; unknown newer versions are returned untouched
  /// (the caller decides to refuse them).
  static Map<String, dynamic> migrate(Map<String, dynamic> json) {
    var data = Map<String, dynamic>.of(json);
    var version = (data['schemaVersion'] as num?)?.toInt() ?? 1;
    while (version < currentSaveSchema) {
      data = switch (version) {
        1 => _v1ToV2(data),
        _ => data,
      };
      version++;
      data['schemaVersion'] = version;
    }
    return data;
  }

  static Map<String, dynamic> _v1ToV2(Map<String, dynamic> v1) {
    final out = Map<String, dynamic>.of(v1);
    final streak = v1['streak'];
    if (streak is num) {
      out['streak'] = {
        'count': streak.toInt(),
        'best': streak.toInt(),
        'lastPlayed': v1['lastPlayed'] ?? '',
      };
    }
    out.remove('lastPlayed');
    return out;
  }
}
