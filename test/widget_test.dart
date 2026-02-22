import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_49_five_minute_workout/app.dart';
import 'package:app_49_five_minute_workout/services/supabase_service.dart';

void main() {
  testWidgets('회원가입 후 할 일을 추가하고 추천 목록에서 확인할 수 있다', (tester) async {
    final service = await SupabaseService.bootstrapFromEnvironment();
    await tester.pumpWidget(EnergyCoachApp(service: service));

    expect(find.text('로그인/회원가입'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('emailField')), 'coach@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');

    await tester.tap(find.text('계정이 없으신가요? 회원가입'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('authSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('5분 홈트 루틴'), findsWidgets);

    await tester.tap(find.byKey(const Key('addTaskFab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('taskTitleField')), '리팩터링 문서 작성');
    await tester.enterText(find.byKey(const Key('taskMinutesField')), '40');
    await tester.enterText(find.byKey(const Key('taskNotesField')), '문서 초안 + 체크리스트');

    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('리팩터링 문서 작성'), findsOneWidget);
    expect(find.textContaining('예상 40분'), findsWidgets);
  });
}
