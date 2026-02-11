import 'package:flutter_test/flutter_test.dart';
import 'package:soupbag/app/app.dart';

void main() {
  testWidgets('P0 壳页面可渲染', (tester) async {
    await tester.pumpWidget(const SoupbagApp());
    await tester.pumpAndSettle();

    expect(find.text('书架'), findsWidgets);
    expect(find.text('发现'), findsOneWidget);
    expect(find.text('阅读'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
