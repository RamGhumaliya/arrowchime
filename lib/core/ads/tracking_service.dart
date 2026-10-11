import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_service.g.dart';

/// The iOS App Tracking Transparency system dialog, behind an interface so
/// tests do not need a device. Does nothing on Android.
abstract interface class TrackingService {
  /// Whether this platform has an ATT dialog at all (iOS).
  bool get supported;

  /// Shows the system dialog (after our own pre-prompt).
  Future<void> requestAuthorization();
}

class SystemTrackingService implements TrackingService {
  const new();

  @override
  bool get supported => Platform.isIOS;

  @override
  Future<void> requestAuthorization() async {
    if (!supported) return;
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

/// A scriptable [TrackingService] for tests.
class FakeTrackingService implements TrackingService {
  new({this.isSupported = true});

  final bool isSupported;
  int requests = 0;

  @override
  bool get supported => isSupported;

  @override
  Future<void> requestAuthorization() async => requests++;
}

@Riverpod(keepAlive: true)
TrackingService trackingService(Ref ref) => const SystemTrackingService();
