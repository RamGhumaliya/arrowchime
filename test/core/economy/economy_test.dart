import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/economy/wallet.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rewards', () {
    test('plain level: 10 + 5 per star', () {
      expect(Rewards.forWin(stars: 3, index: 3).coins, 25);
      expect(Rewards.forWin(stars: 1, index: 3).coins, 15);
    });

    test('knot x1.5, boss x3, flow x5 bonus', () {
      expect(Rewards.forWin(stars: 3, index: 10).coins, 38);
      expect(Rewards.forWin(stars: 3, index: 60).coins, 75);
      expect(Rewards.forWin(stars: 3, index: 3, flowMultiplier: 5).coins, 35);
    });

    test('xp counts stars and flow tiers', () {
      expect(Rewards.forWin(stars: 2, index: 3).xp, 20);
      expect(Rewards.forWin(stars: 2, index: 3, flowMultiplier: 3).xp, 30);
    });
  });

  group('Wallet', () {
    test('adds and spends, never below zero', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final wallet = c.read(walletProvider.notifier);
      expect(c.read(walletProvider), 0);
      wallet
        ..add(0)
        ..add(-5);
      expect(c.read(walletProvider), 0);
      wallet.add(100);
      expect(wallet.trySpend(AppConfig.defaults().heartPrice), isTrue);
      expect(c.read(walletProvider), 0);
      expect(wallet.trySpend(1), isFalse);
      expect(wallet.trySpend(-1), isFalse);
      expect(c.read(walletProvider), 0);
    });
  });
}
