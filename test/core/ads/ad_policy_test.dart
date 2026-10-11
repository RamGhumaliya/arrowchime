import 'package:arrowchime/core/ads/ad_policy.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/remote_config/remote_config_service.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// docs/09 §5 ad tests with a mocked clock: every rule of docs/08 §2.
void main() {
  final p = AdPolicy(AppConfig.defaults());
  const t0 = 1000000000000;
  const minute = 60 * 1000;
  const day = 24 * 60 * minute;

  AdContext win({
    int level = 20,
    bool daily = false,
    bool tutorial = false,
    bool firstOpen = false,
    bool removed = false,
    AdMoment moment = AdMoment.winToNext,
  }) => AdContext(
    moment: moment,
    levelNumber: level,
    isDaily: daily,
    isTutorial: tutorial,
    firstOpen: firstOpen,
    adsRemoved: removed,
  );

  /// A state where the 3rd win is counted and nothing blocks an ad.
  const ready = AdState(winsSinceInterstitial: 3);

  AdDecision ask(AdState s, AdContext c, {int now = t0}) =>
      p.interstitial(s, c, nowMs: now);

  test('the defaults are the docs/08 numbers', () {
    final c = AppConfig.defaults();
    expect(c.interstitialMinLevel, 12);
    expect(c.interstitialEveryNLevels, 3);
    expect(c.interstitialMinSeconds, 150);
    expect(c.interstitialHardGapSeconds, 90);
    expect(c.maxInterstitialsPerHour, 6);
    expect(c.rewardedHeartCap, 2);
    expect(c.doubleCoinsDailyCap, 5);
    expect(c.adHolidayHours, 24);
  });

  group('interstitials', () {
    test('allowed when every condition is met', () {
      expect(ask(ready, win()), AdDecision.allowed);
    });

    test('never before level 12', () {
      expect(ask(ready, win(level: 11)), AdDecision.belowMinLevel);
      expect(ask(ready, win(level: 12)), AdDecision.allowed);
    });

    test('only on the win -> next transition; never on retry or fail', () {
      expect(ask(ready, win(moment: AdMoment.retry)), AdDecision.retryOrFail);
      expect(ask(ready, win(moment: AdMoment.fail)), AdDecision.retryOrFail);
      expect(ask(ready, win(moment: AdMoment.other)), AdDecision.notAfterWin);
    });

    test('never on the first app open, the Daily Knot or the tutorial', () {
      expect(ask(ready, win(firstOpen: true)), AdDecision.firstOpen);
      expect(ask(ready, win(daily: true)), AdDecision.dailyKnot);
      expect(ask(ready, win(tutorial: true)), AdDecision.tutorial);
    });

    test('every 3rd win', () {
      var s = const AdState();
      final seen = <AdDecision>[];
      for (var i = 0; i < 3; i++) {
        s = p.onWin(s);
        seen.add(ask(s, win(), now: t0 + i * 10 * minute));
      }
      expect(seen, [
        AdDecision.notEveryNthWin,
        AdDecision.notEveryNthWin,
        AdDecision.allowed,
      ]);
    });

    test('within 90 s of the previous ad of ANY kind: never', () {
      final s = p.rewardedShown(ready, nowMs: t0);
      expect(ask(s, win(), now: t0 + 89 * 1000), AdDecision.hardGap);
      expect(ask(s, win(), now: t0 + 90 * 1000), AdDecision.allowed);
    });

    test('at least 150 s between interstitials', () {
      final s = p
          .interstitialShown(ready, nowMs: t0)
          .copyWith(winsSinceInterstitial: 3);
      expect(ask(s, win(), now: t0 + 149 * 1000), AdDecision.tooSoon);
      expect(ask(s, win(), now: t0 + 150 * 1000), AdDecision.allowed);
    });

    test('at most 6 an hour', () {
      var s = ready;
      for (var i = 0; i < 6; i++) {
        s = p
            .interstitialShown(s, nowMs: t0 + i * 3 * minute)
            .copyWith(winsSinceInterstitial: 3);
      }
      expect(ask(s, win(), now: t0 + 20 * minute), AdDecision.hourlyCap);
      // The oldest one leaves the window after an hour.
      expect(ask(s, win(), now: t0 + 61 * minute), AdDecision.allowed);
    });

    test('showing one resets the win counter and stamps the times', () {
      final s = p.interstitialShown(ready, nowMs: t0);
      expect(s.winsSinceInterstitial, 0);
      expect(s.lastAdAt, t0);
      expect(s.lastInterstitialAt, t0);
      expect(s.recentInterstitials, [t0]);
    });

    test('caps survive an app restart: the state is plain saved data', () {
      final s = p
          .interstitialShown(ready, nowMs: t0)
          .copyWith(winsSinceInterstitial: 3);
      final restored = AdState.fromJson(s.toJson());
      expect(restored, s);
      expect(ask(restored, win(), now: t0 + 30 * 1000), AdDecision.hardGap);
    });
  });

  group('purchases', () {
    test('Remove Ads: no interstitials immediately', () {
      expect(ask(ready, win(removed: true)), AdDecision.adsRemoved);
    });

    test('any purchase gives a 24 h ad holiday', () {
      final s = p.purchaseMade(ready, nowMs: t0);
      expect(ask(s, win(), now: t0 + 23 * 60 * minute), AdDecision.adHoliday);
      expect(ask(s, win(), now: t0 + 24 * 60 * minute), AdDecision.allowed);
    });

    test('rewarded ads stay available in the holiday', () {
      final s = p.purchaseMade(const AdState(), nowMs: t0);
      expect(p.canOfferHeartAd(0), isTrue);
      expect(p.canOfferDoubleCoins(s, today: '2026-10-10', coins: 20), isTrue);
    });
  });

  group('rewarded caps', () {
    test('+1 heart: at most 2 per level', () {
      expect(p.canOfferHeartAd(0), isTrue);
      expect(p.canOfferHeartAd(1), isTrue);
      expect(p.canOfferHeartAd(2), isFalse);
    });

    test('double coins: 5 a day, resets on a new day, needs coins', () {
      var s = const AdState();
      for (var i = 0; i < 5; i++) {
        expect(
          p.canOfferDoubleCoins(s, today: '2026-10-10', coins: 20),
          isTrue,
        );
        s = p.doubleCoinsUsed(s, today: '2026-10-10');
      }
      expect(p.canOfferDoubleCoins(s, today: '2026-10-10', coins: 20), isFalse);
      expect(p.canOfferDoubleCoins(s, today: '2026-10-11', coins: 20), isTrue);
      expect(p.canOfferDoubleCoins(s, today: '2026-10-11', coins: 0), isFalse);
      expect(p.doubleCoinsUsed(s, today: '2026-10-11').doubleCoinsCount, 1);
    });
  });

  group('iOS ATT pre-prompt (after level 5)', () {
    test('not before 5 levels; then once', () {
      const s = AdState();
      expect(p.shouldAskAtt(s, levelsCleared: 4, nowMs: t0), isFalse);
      expect(p.shouldAskAtt(s, levelsCleared: 5, nowMs: t0), isTrue);
      expect(
        p.shouldAskAtt(p.attAsked(s), levelsCleared: 9, nowMs: t0),
        isFalse,
      );
    });

    test('"maybe later" asks again after 7 days, then never again', () {
      var s = p.attPostponed(const AdState(), nowMs: t0);
      expect(p.shouldAskAtt(s, levelsCleared: 9, nowMs: t0 + 6 * day), isFalse);
      expect(p.shouldAskAtt(s, levelsCleared: 9, nowMs: t0 + 7 * day), isTrue);
      s = p.attPostponed(s, nowMs: t0 + 8 * day);
      expect(
        p.shouldAskAtt(s, levelsCleared: 9, nowMs: t0 + 90 * day),
        isFalse,
      );
    });
  });

  test('Remote Config overrides change the numbers, not the hard rules', () {
    final cfg = AppConfig(
      const LocalRemoteConfig({
        'interstitial_min_level': 3,
        'interstitial_every_n_levels': 1,
      }),
    );
    final loose = AdPolicy(cfg);
    expect(
      loose.interstitial(
        const AdState(winsSinceInterstitial: 1),
        win(level: 3),
        nowMs: t0,
      ),
      AdDecision.allowed,
    );
    expect(
      loose.interstitial(
        const AdState(winsSinceInterstitial: 1),
        win(moment: AdMoment.fail),
        nowMs: t0,
      ),
      AdDecision.retryOrFail,
    );
    expect(
      loose.interstitial(
        const AdState(winsSinceInterstitial: 1),
        win(daily: true),
        nowMs: t0,
      ),
      AdDecision.dailyKnot,
    );
  });
}
