// =============================================================================
//  test/widget_test.dart - "버튼 한 번에 달라지는 두 곳"을 자동으로 확인하는 테스트
// =============================================================================
//
//  실행 방법:  flutter test
//
//  확인하는 내용
//    1) 처음에는 남은 할 일이 2 이고, [완료] 버튼이 2개 있다.
//    2) 첫 번째 [완료] 를 누르면
//       - 남은 할 일 수가 1 로 바뀌고           (바뀌는 곳 ①)
//       - 첫 카드에 ✓ 와 [취소] 버튼이 나타난다  (바뀌는 곳 ②)
//    3) [취소] 를 누르면 다시 처음 상태(2)로 돌아온다.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_state_app/main.dart';

void main() {
  testWidgets('완료 버튼 한 번에 카드 표시와 남은 할 일 수가 함께 바뀐다',
      (WidgetTester tester) async {
    // 앱을 테스트 환경에 띄웁니다.
    await tester.pumpWidget(const TodoStateApp());

    // ── 누르기 전 ──────────────────────────────────────────────────────────
    expect(find.text('나의 할 일'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // 남은 할 일 2
    expect(find.text('완료'), findsNWidgets(2)); // [완료] 버튼 2개
    expect(find.text('취소'), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);

    // 첫 번째 [완료] 버튼을 누르고, setState 로 인한 다시 그리기를 기다립니다.
    await tester.tap(find.text('완료').first);
    await tester.pump();

    // ── 누른 뒤 ────────────────────────────────────────────────────────────
    expect(find.text('1'), findsOneWidget); // ① 남은 할 일 1
    expect(find.text('취소'), findsOneWidget); // ② 첫 카드 버튼이 [취소] 로
    expect(find.text('완료'), findsOneWidget); //    두 번째 카드는 그대로 [완료]
    expect(find.byIcon(Icons.check), findsOneWidget); // ② ✓ 표시

    // ── 다시 [취소] 를 누르면 원래대로 ───────────────────────────────────────
    await tester.tap(find.text('취소'));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('완료'), findsNWidgets(2));
  });
}
