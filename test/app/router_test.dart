import 'package:arrowchime/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to the splash stub', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArrowchimeApp()));
    await tester.pumpAndSettle();
    expect(find.text('Arrowchime'), findsOneWidget);
  });
}
