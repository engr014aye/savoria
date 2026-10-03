import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savoria/main.dart';

void main() {
  testWidgets('Savoria App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const SavoriaApp());
    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}
