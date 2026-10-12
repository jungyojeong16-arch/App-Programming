// =============================================================================
//  test/ledger_store_test.dart - 상태 저장소(LedgerStore)만 따로 검사하는 테스트
// =============================================================================
//
//  상태를 위젯 밖 클래스로 분리하면 좋은 점: 화면을 띄우지 않고도
//  "추가하면 합계가 맞게 바뀌는가?" 같은 계산을 바로 검사할 수 있습니다.
//
//  실행 방법:  flutter test
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:household_ledger/models/ledger_entry.dart';
import 'package:household_ledger/state/ledger_store.dart';

void main() {
  // 각 테스트에서 쓸 기본 저장소: 2026년 10월을 보고 있고, 9월 기록 1건 + 10월 기록 3건
  LedgerStore makeStore() => LedgerStore(
        month: DateTime(2026, 10),
        entries: [
          LedgerEntry(
              title: '9월 용돈',
              amount: 300000,
              category: EntryCategory.allowance,
              date: DateTime(2026, 9, 1)),
          LedgerEntry(
              title: '용돈',
              amount: 500000,
              category: EntryCategory.allowance,
              date: DateTime(2026, 10, 1)),
          LedgerEntry(
              title: '점심',
              amount: 9000,
              category: EntryCategory.food,
              date: DateTime(2026, 10, 2)),
          LedgerEntry(
              title: '버스',
              amount: 30000,
              category: EntryCategory.transport,
              date: DateTime(2026, 10, 3)),
        ],
      );

  test('보고 있는 달의 기록만으로 합계와 잔액을 계산한다', () {
    final store = makeStore();

    expect(store.monthEntries.length, 3); // 9월 기록은 빠짐
    expect(store.incomeTotal, 500000);
    expect(store.expenseTotal, 39000);
    expect(store.balance, 461000);
  });

  test('기록 목록은 최근 날짜가 먼저 온다', () {
    final titles = makeStore().monthEntries.map((e) => e.title).toList();
    expect(titles, ['버스', '점심', '용돈']);
  });

  test('카테고리별 지출은 금액이 큰 순서로 정렬된다', () {
    final items = makeStore().expenseByCategory;
    expect(items.map((e) => e.key).toList(),
        [EntryCategory.transport, EntryCategory.food]);
    expect(items.first.value, 30000);
  });

  test('기록을 추가하면 합계가 바뀌고 구독자에게 알린다', () {
    final store = makeStore();
    int notified = 0;
    store.addListener(() => notified++); // ListenableBuilder 가 하는 일과 같음

    store.add(LedgerEntry(
      title: '저녁',
      amount: 25000,
      category: EntryCategory.food,
      date: DateTime(2026, 10, 4),
    ));

    expect(notified, 1);
    expect(store.expenseTotal, 64000);
    expect(store.expenseByCategory.first.key,
        EntryCategory.food); // 식비 34,000원이 교통 30,000원을 넘어 1등
  });

  test('다른 달의 기록을 추가하면 그 달로 이동한다', () {
    final store = makeStore();
    store.add(LedgerEntry(
      title: '11월 교재',
      amount: 20000,
      category: EntryCategory.education,
      date: DateTime(2026, 11, 3),
    ));

    expect(store.month, DateTime(2026, 11));
    expect(store.monthEntries.single.title, '11월 교재');
  });

  test('기록을 삭제하면 합계에서 빠진다', () {
    final store = makeStore();
    final lunch = store.monthEntries.firstWhere((e) => e.title == '점심');

    store.remove(lunch);

    expect(store.expenseTotal, 30000);
    expect(store.monthEntries.length, 2);
  });

  test('월 이동은 연도를 넘어갈 때도 올바르다', () {
    final store = LedgerStore(month: DateTime(2026, 1));

    store.previousMonth();
    expect(store.month, DateTime(2025, 12));

    store.nextMonth();
    store.nextMonth();
    expect(store.month, DateTime(2026, 2));
  });
}
