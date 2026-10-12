// =============================================================================
//  test/widget_test.dart - 실제 화면을 띄워서 사용자처럼 눌러 보는 테스트
// =============================================================================
//
//  확인하는 내용
//    1) [기록하기] → 금액·내용 입력 → [저장] 하면
//       요약 카드, 지출 분석, 내역 목록이 "함께" 바뀐다.
//    2) 내역을 밀어서 삭제하면 사라지고, [되돌리기]를 누르면 다시 나타난다.
//    3) 입력하지 않고 [저장]을 누르면 안내 문구가 나오고 저장되지 않는다.
//
//  실행 방법:  flutter test
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_ledger/main.dart';
import 'package:household_ledger/models/ledger_entry.dart';
import 'package:household_ledger/state/ledger_store.dart';

void main() {
  // 테스트용 저장소: 이번 달(오늘 기준)에 용돈 500,000원 하나만 있는 상태
  LedgerStore makeStore() {
    final now = DateTime.now();
    return LedgerStore(entries: [
      LedgerEntry(
        title: '용돈',
        amount: 500000,
        category: EntryCategory.allowance,
        date: DateTime(now.year, now.month, 1),
      ),
    ]);
  }

  testWidgets('기록을 추가하면 요약·분석·목록이 함께 바뀐다', (tester) async {
    await tester.pumpWidget(LedgerApp(store: makeStore()));

    // ── 추가 전 ──
    expect(find.text('500,000원'), findsOneWidget); // 잔액
    expect(find.text('내역 1건'), findsOneWidget);
    expect(find.text('이 달의 지출이 없어요'), findsOneWidget);

    // [기록하기] → 입력 화면으로 이동 (화면 전환 애니메이션이 끝날 때까지 대기)
    await tester.tap(find.text('기록하기'));
    await tester.pumpAndSettle();

    // 금액, 내용 입력 (지출 / 식비가 기본 선택)
    await tester.enterText(find.widgetWithText(TextFormField, '금액'), '12000');
    await tester.enterText(find.widgetWithText(TextFormField, '내용'), '저녁 식사');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle(); // 홈 화면으로 돌아옴

    // ── 추가 후: 세 곳이 함께 바뀜 ──
    expect(find.text('488,000원'), findsOneWidget); // ① 잔액 500,000 - 12,000
    expect(find.text('-12,000원'), findsNWidgets(2)); // ① 지출 합계 + ③ 내역 금액
    expect(find.text('내역 2건'), findsOneWidget); // ③ 내역 수
    expect(find.text('저녁 식사'), findsOneWidget); // ③ 새 내역
    expect(find.text('이 달의 지출이 없어요'), findsNothing); // ② 지출 분석 막대 등장
    expect(find.text('100%'), findsOneWidget); // ② 식비 100%
  });

  testWidgets('밀어서 삭제하고 되돌리기로 복구한다', (tester) async {
    await tester.pumpWidget(LedgerApp(store: makeStore()));

    // 내역을 왼쪽으로 밀기
    await tester.drag(find.text('용돈').last, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('내역 0건'), findsOneWidget);
    expect(find.text('0원'), findsOneWidget); // 잔액 0원

    // 아래 알림의 [되돌리기]
    await tester.tap(find.text('되돌리기'));
    await tester.pumpAndSettle();

    expect(find.text('내역 1건'), findsOneWidget);
    expect(find.text('500,000원'), findsOneWidget);
  });

  testWidgets('금액과 내용을 비워 두면 저장되지 않는다', (tester) async {
    await tester.pumpWidget(LedgerApp(store: makeStore()));

    await tester.tap(find.text('기록하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pump();

    expect(find.text('금액을 입력해 주세요'), findsOneWidget);
    expect(find.text('내용을 입력해 주세요'), findsOneWidget);
    expect(find.text('기록하기'), findsOneWidget); // 아직 입력 화면(앱바 제목)
  });
}
