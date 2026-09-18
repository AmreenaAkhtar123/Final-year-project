import 'package:flutter_test/flutter_test.dart';

import 'package:fyp_project_mental_health/main.dart';

void main() {
  testWidgets('MindMate app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MindMateApp());

    expect(find.byType(MindMateApp), findsOneWidget);
  });
}