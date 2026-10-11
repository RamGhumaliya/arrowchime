// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakState _$StreakStateFromJson(Map<String, dynamic> json) => _StreakState(
  count: (json['count'] as num?)?.toInt() ?? 0,
  best: (json['best'] as num?)?.toInt() ?? 0,
  lastPlayed: json['lastPlayed'] as String? ?? '',
  freezes: (json['freezes'] as num?)?.toInt() ?? 0,
  freezeWeek: json['freezeWeek'] as String? ?? '',
);

Map<String, dynamic> _$StreakStateToJson(_StreakState instance) =>
    <String, dynamic>{
      'count': instance.count,
      'best': instance.best,
      'lastPlayed': instance.lastPlayed,
      'freezes': instance.freezes,
      'freezeWeek': instance.freezeWeek,
    };

_DailyResult _$DailyResultFromJson(Map<String, dynamic> json) => _DailyResult(
  stars: (json['stars'] as num?)?.toInt() ?? 0,
  heartsLeft: (json['heartsLeft'] as num?)?.toInt() ?? 0,
  bestFlow: (json['bestFlow'] as num?)?.toInt() ?? 1,
  seconds: (json['seconds'] as num?)?.toInt() ?? 0,
  replayed: json['replayed'] as bool? ?? false,
);

Map<String, dynamic> _$DailyResultToJson(_DailyResult instance) =>
    <String, dynamic>{
      'stars': instance.stars,
      'heartsLeft': instance.heartsLeft,
      'bestFlow': instance.bestFlow,
      'seconds': instance.seconds,
      'replayed': instance.replayed,
    };

_QuestProgress _$QuestProgressFromJson(Map<String, dynamic> json) =>
    _QuestProgress(
      id: json['id'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      claimed: json['claimed'] as bool? ?? false,
    );

Map<String, dynamic> _$QuestProgressToJson(_QuestProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'progress': instance.progress,
      'claimed': instance.claimed,
    };

_QuestState _$QuestStateFromJson(Map<String, dynamic> json) => _QuestState(
  date: json['date'] as String? ?? '',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => QuestProgress.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <QuestProgress>[],
  chestOpened: json['chestOpened'] as bool? ?? false,
);

Map<String, dynamic> _$QuestStateToJson(_QuestState instance) =>
    <String, dynamic>{
      'date': instance.date,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'chestOpened': instance.chestOpened,
    };

_PlayStats _$PlayStatsFromJson(Map<String, dynamic> json) => _PlayStats(
  arrowsFreed: (json['arrowsFreed'] as num?)?.toInt() ?? 0,
  levelsCleared: (json['levelsCleared'] as num?)?.toInt() ?? 0,
  perfectClears: (json['perfectClears'] as num?)?.toInt() ?? 0,
  perfectRun: (json['perfectRun'] as num?)?.toInt() ?? 0,
  bestFlow: (json['bestFlow'] as num?)?.toInt() ?? 1,
  blockedTaps: (json['blockedTaps'] as num?)?.toInt() ?? 0,
  playSeconds: (json['playSeconds'] as num?)?.toInt() ?? 0,
  dailiesPlayed: (json['dailiesPlayed'] as num?)?.toInt() ?? 0,
  hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayStatsToJson(_PlayStats instance) =>
    <String, dynamic>{
      'arrowsFreed': instance.arrowsFreed,
      'levelsCleared': instance.levelsCleared,
      'perfectClears': instance.perfectClears,
      'perfectRun': instance.perfectRun,
      'bestFlow': instance.bestFlow,
      'blockedTaps': instance.blockedTaps,
      'playSeconds': instance.playSeconds,
      'dailiesPlayed': instance.dailiesPlayed,
      'hintsUsed': instance.hintsUsed,
    };

_SaveSettings _$SaveSettingsFromJson(Map<String, dynamic> json) =>
    _SaveSettings(
      musicOn: json['musicOn'] as bool? ?? true,
      soundOn: json['soundOn'] as bool? ?? true,
      hapticsOn: json['hapticsOn'] as bool? ?? true,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 1.0,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 1.0,
      leftHanded: json['leftHanded'] as bool? ?? false,
      relaxed: json['relaxed'] as bool? ?? false,
      gridOn: json['gridOn'] as bool? ?? false,
      reduceMotion: json['reduceMotion'] as String? ?? 'system',
      colorBlind: json['colorBlind'] as String? ?? 'off',
    );

Map<String, dynamic> _$SaveSettingsToJson(_SaveSettings instance) =>
    <String, dynamic>{
      'musicOn': instance.musicOn,
      'soundOn': instance.soundOn,
      'hapticsOn': instance.hapticsOn,
      'musicVolume': instance.musicVolume,
      'soundVolume': instance.soundVolume,
      'leftHanded': instance.leftHanded,
      'relaxed': instance.relaxed,
      'gridOn': instance.gridOn,
      'reduceMotion': instance.reduceMotion,
      'colorBlind': instance.colorBlind,
    };

_AdState _$AdStateFromJson(Map<String, dynamic> json) => _AdState(
  lastAdAt: (json['lastAdAt'] as num?)?.toInt() ?? 0,
  lastInterstitialAt: (json['lastInterstitialAt'] as num?)?.toInt() ?? 0,
  recentInterstitials:
      (json['recentInterstitials'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  winsSinceInterstitial: (json['winsSinceInterstitial'] as num?)?.toInt() ?? 0,
  holidayUntil: (json['holidayUntil'] as num?)?.toInt() ?? 0,
  doubleCoinsDate: json['doubleCoinsDate'] as String? ?? '',
  doubleCoinsCount: (json['doubleCoinsCount'] as num?)?.toInt() ?? 0,
  attState: json['attState'] as String? ?? '',
  attRetryAt: (json['attRetryAt'] as num?)?.toInt() ?? 0,
  starterOfferedAt: (json['starterOfferedAt'] as num?)?.toInt() ?? 0,
  starterShownDate: json['starterShownDate'] as String? ?? '',
);

Map<String, dynamic> _$AdStateToJson(_AdState instance) => <String, dynamic>{
  'lastAdAt': instance.lastAdAt,
  'lastInterstitialAt': instance.lastInterstitialAt,
  'recentInterstitials': instance.recentInterstitials,
  'winsSinceInterstitial': instance.winsSinceInterstitial,
  'holidayUntil': instance.holidayUntil,
  'doubleCoinsDate': instance.doubleCoinsDate,
  'doubleCoinsCount': instance.doubleCoinsCount,
  'attState': instance.attState,
  'attRetryAt': instance.attRetryAt,
  'starterOfferedAt': instance.starterOfferedAt,
  'starterShownDate': instance.starterShownDate,
};

_SaveData _$SaveDataFromJson(Map<String, dynamic> json) => _SaveData(
  schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? currentSaveSchema,
  seq: (json['seq'] as num?)?.toInt() ?? 0,
  stars:
      (json['stars'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{},
  currentLevel:
      (json['currentLevel'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const <String, int>{'1': 1},
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  inventory:
      (json['inventory'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  equipped:
      (json['equipped'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  streak: json['streak'] == null
      ? const StreakState()
      : StreakState.fromJson(json['streak'] as Map<String, dynamic>),
  daily:
      (json['daily'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, DailyResult.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, DailyResult>{},
  achievements:
      (json['achievements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  quests: json['quests'] == null
      ? const QuestState()
      : QuestState.fromJson(json['quests'] as Map<String, dynamic>),
  settings: json['settings'] == null
      ? const SaveSettings()
      : SaveSettings.fromJson(json['settings'] as Map<String, dynamic>),
  stats: json['stats'] == null
      ? const PlayStats()
      : PlayStats.fromJson(json['stats'] as Map<String, dynamic>),
  flags:
      (json['flags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const <String, bool>{},
  ads: json['ads'] == null
      ? const AdState()
      : AdState.fromJson(json['ads'] as Map<String, dynamic>),
  purchases:
      (json['purchases'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$SaveDataToJson(_SaveData instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'seq': instance.seq,
  'stars': instance.stars,
  'currentLevel': instance.currentLevel,
  'coins': instance.coins,
  'xp': instance.xp,
  'inventory': instance.inventory,
  'equipped': instance.equipped,
  'streak': instance.streak.toJson(),
  'daily': instance.daily.map((k, e) => MapEntry(k, e.toJson())),
  'achievements': instance.achievements,
  'quests': instance.quests.toJson(),
  'settings': instance.settings.toJson(),
  'stats': instance.stats.toJson(),
  'flags': instance.flags,
  'ads': instance.ads.toJson(),
  'purchases': instance.purchases,
  'updatedAt': instance.updatedAt,
};
