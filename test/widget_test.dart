import 'package:flutter_test/flutter_test.dart';
import 'package:app_49_five_minute_workout/main.dart';

void main() {
  testWidgets('앱 타이틀 렌더링', (tester) async {
    await tester.pumpWidget(const IdeaApp());
    expect(find.textContaining('5분'), findsWidgets);
  });
}
