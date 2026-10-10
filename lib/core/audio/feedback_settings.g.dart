// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedbackSettingsController)
final feedbackSettingsControllerProvider =
    FeedbackSettingsControllerProvider._();

final class FeedbackSettingsControllerProvider
    extends $NotifierProvider<FeedbackSettingsController, FeedbackSettings> {
  FeedbackSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackSettingsControllerHash();

  @$internal
  @override
  FeedbackSettingsController create() => FeedbackSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedbackSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedbackSettings>(value),
    );
  }
}

String _$feedbackSettingsControllerHash() =>
    r'0c9b757c9435f66fc90150f201f900a3f0bc26ef';

abstract class _$FeedbackSettingsController
    extends $Notifier<FeedbackSettings> {
  FeedbackSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FeedbackSettings, FeedbackSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedbackSettings, FeedbackSettings>,
              FeedbackSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
