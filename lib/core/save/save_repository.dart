import 'dart:convert';

import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/save/save_migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// A tiny string key-value store, so the save logic can be tested without
/// Hive.
abstract interface class SaveStore {
  String? read(String key);

  Future<void> write(String key, String value);
}

/// [SaveStore] on a Hive box (`save`, `docs/05` §6).
class HiveSaveStore implements SaveStore {
  new(this._box);

  final Box<String> _box;

  /// Opens the box under [path].
  static Future<HiveSaveStore> open(String path) async {
    Hive.init(path);
    return HiveSaveStore(await Hive.openBox<String>('save'));
  }

  /// Opens the box in the app's documents folder (the real app).
  static Future<HiveSaveStore> openInApp() async {
    await Hive.initFlutter();
    return HiveSaveStore(await Hive.openBox<String>('save'));
  }

  @override
  String? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);
}

/// In-memory [SaveStore] (tests, previews).
class MemorySaveStore implements SaveStore {
  final Map<String, String> data = {};

  @override
  String? read(String key) => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

/// Loads and saves [SaveData] atomically: two slots are written alternately,
/// each carrying a write counter, so a kill in the middle of a write can only
/// damage the slot being written and the previous good save is still read.
class SaveRepository {
  new(this._store);

  final SaveStore _store;

  static const List<String> slots = ['slot0', 'slot1'];

  /// The newest valid save, or a fresh one.
  SaveData load() {
    SaveData? best;
    for (final slot in slots) {
      final data = _parse(_store.read(slot));
      if (data != null && (best == null || data.seq > best.seq)) best = data;
    }
    return best ?? SaveData.initial();
  }

  SaveData? _parse(String? text) {
    if (text == null) return null;
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) return null;
      final version = (json['schemaVersion'] as num?)?.toInt() ?? 1;
      if (version > currentSaveSchema) return null;
      return SaveData.fromJson(SaveMigrations.migrate(json));
    } on Object catch (e) {
      debugPrint('SaveRepository: unreadable slot ($e)');
      return null;
    }
  }

  /// Writes [data] and returns it with its new write counter.
  Future<SaveData> save(SaveData data) async {
    final next = data.copyWith(seq: data.seq + 1);
    await _store.write(slots[next.seq % 2], jsonEncode(next.toJson()));
    return next;
  }
}
