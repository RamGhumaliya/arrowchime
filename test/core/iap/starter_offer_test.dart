import 'package:arrowchime/core/iap/purchase_fulfillment.dart';
import 'package:arrowchime/core/iap/starter_offer.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final config = AppConfig.defaults();
  const t0 = 1000000000000;
  const hour = 3600 * 1000;
  SaveData after15({AdState ads = const AdState()}) =>
      SaveData(stats: const PlayStats(levelsCleared: 15), ads: ads);

  StarterOffer at(SaveData d, int now, {String today = '2026-10-10'}) =>
      StarterOffer.of(d, config, nowMs: now, today: today);

  test('closed before level 15', () {
    expect(
      at(const SaveData(stats: PlayStats(levelsCleared: 14)), t0).open,
      isFalse,
    );
    expect(at(after15(), t0).open, isTrue);
  });

  test('first prompt opens the 48 h window', () {
    final first = at(after15(), t0);
    expect(first.promptToday, isTrue);
    expect(first.remaining, const Duration(hours: 48));
    final d = StarterOffer.shown(after15(), nowMs: t0, today: '2026-10-10');
    expect(d.ads.starterOfferedAt, t0);
    expect(at(d, t0 + 10 * hour).remaining, const Duration(hours: 38));
  });

  test('shown at most once a day; again the next day', () {
    final d = StarterOffer.shown(after15(), nowMs: t0, today: '2026-10-10');
    expect(at(d, t0 + hour).promptToday, isFalse);
    expect(at(d, t0 + 25 * hour, today: '2026-10-11').promptToday, isTrue);
  });

  test('showing again keeps the original start', () {
    var d = StarterOffer.shown(after15(), nowMs: t0, today: '2026-10-10');
    d = StarterOffer.shown(d, nowMs: t0 + 30 * hour, today: '2026-10-11');
    expect(d.ads.starterOfferedAt, t0);
  });

  test('expires after 48 h', () {
    final d = StarterOffer.shown(after15(), nowMs: t0, today: '2026-10-10');
    expect(at(d, t0 + 47 * hour).open, isTrue);
    expect(at(d, t0 + 48 * hour).open, isFalse);
    expect(at(d, t0 + 48 * hour).remaining, Duration.zero);
  });

  test('hidden once bought or when Remove Ads is owned; Remote Config can turn it off', () {
    final bought = after15().copyWith(
      purchases: [PurchaseFulfillment.marker(StarterOffer.productId)],
    );
    expect(at(bought, t0).open, isFalse);
    final removed = after15().copyWith(flags: {'adsRemoved': true});
    expect(at(removed, t0).open, isFalse);
    expect(StarterOffer.closed.open, isFalse);
  });
}
