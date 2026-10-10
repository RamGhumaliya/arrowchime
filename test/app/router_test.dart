import 'package:flutter_test/flutter_test.dart';

import '../features/game/support/game_harness.dart';
import '../features/meta/meta_harness.dart';

void main() {
  testWidgets('the app boots to the splash, then opens Home', (tester) async {
    await pumpApp(tester, location: '/');
    expect(find.text('Arrowchime'), findsWidgets);
    await settle(tester, frames: 40);
    expect(find.text('PLAY · Level 1'), findsWidgets);
  });
}
