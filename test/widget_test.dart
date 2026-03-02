import 'package:flutter_test/flutter_test.dart';
import 'package:fancy_shop_admin/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FancyShopAdminApp());
    expect(find.byType(FancyShopAdminApp), findsOneWidget);
  });
}
