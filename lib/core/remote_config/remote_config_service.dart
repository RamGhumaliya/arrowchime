import 'package:arrowchime/core/remote_config/defaults.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_config_service.g.dart';

/// Where tunables come from. The Firebase implementation arrives in Phase 9;
/// until then (and offline) values come from [RemoteDefaults].
abstract interface class RemoteConfigService {
  int getInt(String key);

  bool getBool(String key);

  String getString(String key);
}

/// Defaults plus optional [overrides] (tests, and later fetched values).
class LocalRemoteConfig implements RemoteConfigService {
  const new([this.overrides = const {}]);

  final Map<String, Object> overrides;

  Object _value(String key) =>
      overrides[key] ??
      RemoteDefaults.values[key] ??
      (throw ArgumentError('unknown config key $key'));

  @override
  int getInt(String key) => _value(key) as int;

  @override
  bool getBool(String key) => _value(key) as bool;

  @override
  String getString(String key) => _value(key) as String;
}

@Riverpod(keepAlive: true)
RemoteConfigService remoteConfig(Ref ref) => const LocalRemoteConfig();
